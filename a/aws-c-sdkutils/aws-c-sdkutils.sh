#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : aws-c-sdkutils
# Version       : v0.1.6
# Source repo   : https://github.com/awslabs/aws-c-sdkutils
# Tested on     : UBI:9.3
# Language      : C
# Script License: Apache License, Version 2 or later
# Maintainer    : Pranjal-Patidar1 <pranjal.patidar1@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
#                 platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - aws-c-sdkutils is a C99 library implementing AWS SDK specific utilities
#     (ARN parsing, AWS profile reading, etc).
#   - This is a pure C library with no PyPI package (pypi.org returns 404), so
#     NOARCH=false: it must be built from source and shipped as a wheel.
#   - custom_install() builds aws-c-common (full install) and aws-c-sdkutils
#     (build only, staged from the build tree), then stages the built .so
#     files into python_package/aws_c_sdkutils/ and builds the wheel with
#     "python -m build --wheel --no-isolation" using the sidecar
#     setup.py / pyproject.toml / MANIFEST.in from this script directory.
#   - setup.py uses NativeDistribution + NativePayloadWheel (subclassing
#     setuptools/wheel) to produce a py3-none-<platform> wheel, matching the
#     aws-c-common / aws-c-compression packaging pattern.
#   - custom_test_command() runs ctest against the already-built tree and then
#     runs the wheel smoke test (aws_c_sdkutils_smoke.py).
#   - aws-c-common is pinned to v0.8.5, matching the aws-c-common wheel already
#     built in this repo (override with AWS_C_COMMON_TAG).
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="aws-c-sdkutils"
PACKAGE_VERSION="${1:-v0.1.6}"
PACKAGE_URL="https://github.com/awslabs/aws-c-sdkutils"

NOARCH="false"

RH_DEP_PKGS="git cmake make gcc gcc-c++"
DEB_DEP_PKGS="git cmake make gcc g++"
SLES_DEP_PKGS="git cmake make gcc gcc-c++"

INSTALL_PREFIX="/tmp/aws-build"
PKG_VER="${PACKAGE_VERSION#v}"
AWS_C_COMMON_TAG="${AWS_C_COMMON_TAG:-v0.8.5}"

custom_install() {
    local SOURCE_DIR="/workspace/aws-c-sdkutils"

    # -------------------------------------------------------------------------
    # 1. Build aws-c-common dependency
    # -------------------------------------------------------------------------
    log_info "Building aws-c-common ${AWS_C_COMMON_TAG} dependency..."
    rm -rf /tmp/aws-c-common
    git clone --depth 1 --branch "${AWS_C_COMMON_TAG}" \
        https://github.com/awslabs/aws-c-common.git /tmp/aws-c-common
    cmake -S /tmp/aws-c-common -B /tmp/aws-c-common/build \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_TESTING=OFF
    cmake --build /tmp/aws-c-common/build --parallel "$(nproc)"
    cmake --install /tmp/aws-c-common/build

    # -------------------------------------------------------------------------
    # 2. Build aws-c-sdkutils
    #    (not installed: the .so is staged directly from the build tree)
    # -------------------------------------------------------------------------
    log_info "Building aws-c-sdkutils ${PACKAGE_VERSION}..."
    cmake -S "${SOURCE_DIR}" -B "${SOURCE_DIR}/build" \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        -DCMAKE_PREFIX_PATH="${INSTALL_PREFIX}" \
        -DCMAKE_MODULE_PATH="${INSTALL_PREFIX}/lib64/cmake/aws-c-common/modules" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_TESTING=ON
    cmake --build "${SOURCE_DIR}/build" --parallel "$(nproc)"

    # -------------------------------------------------------------------------
    # 3. Stage .so files into python_package/aws_c_sdkutils/
    # -------------------------------------------------------------------------
    log_info "Staging native .so files for wheel packaging..."
    pip install --upgrade setuptools wheel build

    local PAYLOAD_DIR="${SOURCE_DIR}/python_package/aws_c_sdkutils"
    rm -rf "${SOURCE_DIR}/python_package" "${SOURCE_DIR}/dist" "${SOURCE_DIR}/build_wheel"
    mkdir -p "${PAYLOAD_DIR}"

    # aws-c-sdkutils .so (built but not installed — pick from build tree)
    local SO_SRC
    SO_SRC=$(find "${SOURCE_DIR}/build" -name "libaws-c-sdkutils.so*" | head -1)
    if [ -z "${SO_SRC}" ]; then
        log_error "libaws-c-sdkutils.so not found in build tree"
        return 1
    fi
    cp -a "${SO_SRC%/*}"/libaws-c-sdkutils.so* "${PAYLOAD_DIR}/"

    # aws-c-common .so files (installed into INSTALL_PREFIX)
    cp -a "${INSTALL_PREFIX}/lib64/libaws-c-common.so"* "${PAYLOAD_DIR}/" 2>/dev/null || \
        cp -a "${INSTALL_PREFIX}/lib/libaws-c-common.so"* "${PAYLOAD_DIR}/" 2>/dev/null || true

    # Copy sidecar packaging files from script directory into source root
    cp "${SCRIPT_DIR}/__init__.py"    "${PAYLOAD_DIR}/__init__.py"
    cp "${SCRIPT_DIR}/setup.py"       "${SOURCE_DIR}/setup.py"
    cp "${SCRIPT_DIR}/pyproject.toml" "${SOURCE_DIR}/pyproject.toml"
    cp "${SCRIPT_DIR}/MANIFEST.in"    "${SOURCE_DIR}/MANIFEST.in"

    # -------------------------------------------------------------------------
    # 4. Build the wheel with python -m build (no isolated env — deps already
    #    installed above)
    # -------------------------------------------------------------------------
    log_info "Building aws-c-sdkutils wheel..."
    export AWS_C_SDKUTILS_VERSION="${PKG_VER}"
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
        cd /workspace/aws-c-sdkutils/build
        ctest --output-on-failure
    )

    log_info "Running aws-c-sdkutils wheel smoke test..."
    (cd /tmp && python -I "${SCRIPT_DIR}/aws_c_sdkutils_smoke.py" "${PKG_VER}")
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"
