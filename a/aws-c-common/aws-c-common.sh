#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : aws-c-common
# Version       : v1.0.0
# Source repo   : https://github.com/awslabs/aws-c-common
# Tested on     : UBI:9.3
# Language      : C
# Script License: Apache License, Version 2 or later
# Maintainer    : Pranjal-Patidar1 <pranjal.patidar1@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on the given
#                 platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="aws-c-common"
PACKAGE_VERSION="${1:-v1.0.0}"
PACKAGE_URL="https://github.com/awslabs/aws-c-common"
NOARCH="false"

RH_DEP_PKGS="git cmake make gcc gcc-c++"
DEB_DEP_PKGS="git cmake make gcc g++"
SLES_DEP_PKGS="git cmake make gcc gcc-c++"

INSTALL_PREFIX="/tmp/aws-build"
PKG_VER="${PACKAGE_VERSION#v}"

custom_install() {
    local SOURCE_DIR="/workspace/aws-c-common"

    # 1. Build aws-c-common from source
    log_info "Building aws-c-common ${PACKAGE_VERSION}..."
    cmake -S "${SOURCE_DIR}" -B "${SOURCE_DIR}/build" \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_TESTING=ON
    cmake --build "${SOURCE_DIR}/build" --parallel "$(nproc)"
    cmake --install "${SOURCE_DIR}/build"

    # 2. Stage .so files into python_package/aws_c_common/
    log_info "Staging native .so files for wheel packaging..."
    pip install --upgrade setuptools wheel build

    local PAYLOAD_DIR="${SOURCE_DIR}/python_package/aws_c_common"
    rm -rf "${SOURCE_DIR}/python_package" "${SOURCE_DIR}/dist"
    mkdir -p "${PAYLOAD_DIR}"

    cp "${INSTALL_PREFIX}/lib64/libaws-c-common.so"* "${PAYLOAD_DIR}/" 2>/dev/null || \
        cp "${INSTALL_PREFIX}/lib/libaws-c-common.so"* "${PAYLOAD_DIR}/" 2>/dev/null || true

    cp "${SCRIPT_DIR}/__init__.py"    "${PAYLOAD_DIR}/__init__.py"
    cp "${SCRIPT_DIR}/setup.py"       "${SOURCE_DIR}/setup.py"
    cp "${SCRIPT_DIR}/pyproject.toml" "${SOURCE_DIR}/pyproject.toml"
    cp "${SCRIPT_DIR}/MANIFEST.in"    "${SOURCE_DIR}/MANIFEST.in"

    # 3. Build the wheel
    log_info "Building aws-c-common wheel..."
    export AWS_C_COMMON_VERSION="${PKG_VER}"
    (
        cd "${SOURCE_DIR}"
        python -m build --wheel --no-isolation
    )

    log_info "Wheel built:"
    ls -lh "${SOURCE_DIR}/dist/"
}

custom_test_command() {
    log_info "Running ctest..."
    export LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib64:${INSTALL_PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    (
        cd /workspace/aws-c-common/build
        ctest --output-on-failure
    ) || { log_error "ctest failed"; return 1; }

    log_info "Running aws-c-common wheel smoke test..."
    (cd /tmp && python -I "${SCRIPT_DIR}/aws_c_common_smoke.py" "${PKG_VER}")
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"
