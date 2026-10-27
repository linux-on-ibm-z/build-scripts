#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : libssh2
# Version       : libssh2-1.11.1
# Source repo   : https://github.com/libssh2/libssh2
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
#     setuptools shim, and publishes the artifact for consumers via BUILD_DEPS
#
# Notes:
#   - C library implementing the SSH2 protocol; no Python component upstream
#   - custom_install() builds the library, wraps the installed prefix in a
#   - License is COPYING; LICENSE_FILE tells _copy_license where to find it
#   - openssl-devel and zlib-devel are required by cmake crypto detection
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="libssh2"
PACKAGE_VERSION="${1:-libssh2-1.11.1}"
PACKAGE_URL="https://github.com/libssh2/libssh2"

# OPTIONAL: Build configuration
PROVIDES_ARTIFACT="libssh2"
ARTIFACT_VERSION="${PACKAGE_VERSION#libssh2-}"
# upstream licence is named COPYING; the helper searches by this name
LICENSE_FILE="COPYING"
LICENSE_SPDX="BSD-3-Clause"

# REQUIRED: Dependencies
RH_DEP_PKGS="cmake gcc-c++ make openssl-devel zlib-devel"

# CALLBACK: custom_install
#   and wrap the installed prefix in a setuptools wheel shim
custom_install() {
    local prefix
    prefix="$(artifact_dir "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}")"

    # Build and install the native library into the artifact prefix
    mkdir -p build
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${prefix}" \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_STATIC_LIBS=ON \
        -DBUILD_TESTING=ON \
        -DRUN_DOCKER_TESTS=OFF \
        -DRUN_SSHD_TESTS=OFF
    cmake --build build --parallel "$(nproc)"
    cmake --install build

    # Publish the artifact
    _cleanup_artifact "${prefix}"
    _copy_license "${prefix}"
    _generate_env_sh "${prefix}" "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}"
    generate_artifact_manifest "${prefix}" "${PROVIDES_ARTIFACT}" \
        "${ARTIFACT_VERSION}" "${PACKAGE_URL}" "${LICENSE_SPDX}"

    # Wrap the installed prefix in a setuptools shim so the wheel ships
    # the shared objects and headers alongside the Python package marker
    local staging="${PWD}/staging"
    rm -rf "${staging}"
    mkdir -p "${staging}/libssh2"

    # Copy the entire installed tree into the package subdirectory
    cp -r "${prefix}/." "${staging}/libssh2/"
    rm -f "${staging}/libssh2/env.sh" "${staging}/libssh2/manifest.json"
    touch "${staging}/libssh2/__init__.py"

    # Place the licence inside the package so it ships in the wheel
    _copy_license "${staging}/libssh2"

    # Install static packaging files from SCRIPT_DIR (read-only bind-mount)
    sed "s/@VERSION@/${ARTIFACT_VERSION}/" "${SCRIPT_DIR}/setup.py" \
        > "${staging}/setup.py"
    cp "${SCRIPT_DIR}/pyproject.toml" "${staging}/pyproject.toml"
    cp "${SCRIPT_DIR}/MANIFEST.in"    "${staging}/MANIFEST.in"

    # Build the wheel; --no-isolation makes pre_build() installs visible
    python -m build --no-isolation --wheel --outdir "${PWD}/dist" "${staging}"
}

# CALLBACK: custom_test_command
#   docker/sshd integration tests are skipped (require network fixtures)
custom_test_command() {
    ctest --test-dir build --output-on-failure
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
