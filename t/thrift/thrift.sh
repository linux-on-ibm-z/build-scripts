#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : thrift
# Version       : v0.25.0
# Source repo   : https://github.com/apache/thrift
# Tested on     : UBI:9.8
# Language      : C/C++
# Script License: Apache License, Version 2 or later
# Maintainer    : Sai-Sindhuri-Avulamanda <Sai.Sindhuri.Avulamanda@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
# ==========      platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - Python package lives in lib/py/ with upstream's own setup.py and C extension
#   - C extension (thrift.protocol.fastbinary) makes the wheel architecture-specific; setuptools>=69 required
#   - System packages: bison/flex build the thrift compiler, which generates the pytest stubs
#   - WITH_CPP=OFF: Boost (needed only by lib/cpp) is in no enabled repo, and the wheel ships no C++ lib
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="thrift"
PACKAGE_VERSION="${1:-v0.25.0}"
PACKAGE_URL="https://github.com/apache/thrift"

# OPTIONAL: Build configuration
PROVIDES_ARTIFACT="thrift"
ARTIFACT_VERSION="${PACKAGE_VERSION#v}"
LICENSE_SPDX="Apache-2.0"

# REQUIRED: Dependencies
RH_DEP_PKGS="cmake gcc-c++ bison flex openssl-devel zlib-devel"

# OPTIONAL: Build configuration
# lib/py/pyproject.toml requires setuptools>=69; override the template's <70 pin
SETUPTOOLS_VERSION=">=69,<82"

# CALLBACK: custom_install: replaces the default install step
custom_install() {
    local prefix
    prefix="$(artifact_dir "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}")"

    # Build and install the C++ thrift libraries into the artifact prefix
    mkdir -p cmake_build
    cmake -S . -B cmake_build \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_LIBRARIES=ON \
        -DWITH_CPP=OFF \
        -DBUILD_TESTING=ON \
        -DWITH_OPENSSL=ON \
        -DTHRIFT_MAX_MESSAGE_SIZE=104857600 \
        -DBUILD_JAVA=OFF \
        -DBUILD_JAVASCRIPT=OFF \
        -DBUILD_NODEJS=OFF \
        -DCMAKE_INSTALL_PREFIX="${prefix}" || return 1
    cmake --build cmake_build --parallel "$(nproc)" || return 1
    cmake --install cmake_build || return 1

    # Complete the artifact contract
    _cleanup_artifact "${prefix}"
    _copy_license "${prefix}"
    _generate_env_sh "${prefix}" "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}"
    generate_artifact_manifest "${prefix}" "${PROVIDES_ARTIFACT}" \
        "${ARTIFACT_VERSION}" "${PACKAGE_URL}" "${LICENSE_SPDX}"

    # Build the Python wheel from upstream's own lib/py/ packaging
    python -m build --no-isolation --wheel lib/py --outdir dist || return 1
}

# CALLBACK: pre_test: installs test prerequisites
pre_test() {
    pip install "tornado>=6.3.0" "twisted>=24.3.0" "zope.interface>=6.1"
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    local prefix
    prefix="$(artifact_dir "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}")"
    local thrift_bin="${prefix}/bin/thrift"
    if [ ! -x "${thrift_bin}" ]; then
        thrift_bin="${PWD}/cmake_build/bin/thrift"
    fi

    ctest --test-dir cmake_build --output-on-failure

    (
        cd lib/py
        "${thrift_bin}" --gen py test/test_thrift_file/TestServer.thrift
        "${thrift_bin}" --gen py ../../test/v0.16/FuzzTestNoUuid.thrift
        "${thrift_bin}" --gen py ../../test/Recursive.thrift
        "${thrift_bin}" --gen py:dynamic test/test_thrift_file/RecursiveDynamic.thrift
    )

    THRIFT="${thrift_bin}" pytest lib/py/test
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
