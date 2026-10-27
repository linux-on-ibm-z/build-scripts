#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : leveldb
# Version       : 1.23
# Source repo   : https://github.com/google/leveldb
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
#   - C++ key-value storage library built with cmake; no Python component upstream
#   - custom_install() builds the library, wraps the installed prefix in a
#   - License file is LICENSE; _copy_license locates it by default
#   - C++ library built with cmake
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="leveldb"
PACKAGE_VERSION="${1:-1.23}"
PACKAGE_URL="https://github.com/google/leveldb"

# OPTIONAL: Build configuration
PROVIDES_ARTIFACT="leveldb"
ARTIFACT_VERSION="${PACKAGE_VERSION}"

# REQUIRED: Dependencies
RH_DEP_PKGS="cmake"

# CALLBACK: custom_install
#   and wraps the installed prefix in a setuptools wheel shim
custom_install() {
    local prefix
    prefix="$(artifact_dir "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}")"

    # Build and install the native library into the artifact prefix
    mkdir -p build
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${prefix}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DLEVELDB_BUILD_TESTS=OFF \
        -DLEVELDB_BUILD_BENCHMARKS=OFF \
        -DLEVELDB_INSTALL=ON
    cmake --build build --parallel "$(nproc)"
    cmake --install build

    # Publish the artifact
    _cleanup_artifact "${prefix}"
    _copy_license "${prefix}"
    _generate_env_sh "${prefix}" "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}"
    generate_artifact_manifest "${prefix}" "${PROVIDES_ARTIFACT}" \
        "${ARTIFACT_VERSION}" "${PACKAGE_URL}" "BSD-3-Clause"

    # Wrap the installed prefix in a setuptools shim so the wheel ships
    # the shared objects and headers alongside the Python package marker
    local staging="${PWD}/staging"
    rm -rf "${staging}"
    mkdir -p "${staging}/leveldb"

    # Copy the entire installed tree into the package subdirectory
    cp -r "${prefix}/." "${staging}/leveldb/"
    rm -f "${staging}/leveldb/env.sh" "${staging}/leveldb/manifest.json"
    touch "${staging}/leveldb/__init__.py"

    # Place the licence inside the package so it ships in the wheel
    _copy_license "${staging}/leveldb"

    # Install static packaging files from SCRIPT_DIR (read-only bind-mount)
    sed "s/@VERSION@/${ARTIFACT_VERSION}/" "${SCRIPT_DIR}/setup.py" \
        > "${staging}/setup.py"
    cp "${SCRIPT_DIR}/pyproject.toml" "${staging}/pyproject.toml"
    cp "${SCRIPT_DIR}/MANIFEST.in"    "${staging}/MANIFEST.in"

    # Build the wheel; --no-isolation makes pre_build() installs visible
    python -m build --no-isolation --wheel --outdir "${PWD}/dist" "${staging}"
}

# CALLBACK: custom_test_command
#   Build and run the C++ test suite with cmake/ctest.
# Uses BUILD_SHARED_LIBS=OFF so CMakeLists.txt's full test set is included
# (lines 352-385 of CMakeLists.txt gate most tests on NOT BUILD_SHARED_LIBS).
custom_test_command() {
    cmake -S . -B build-test \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DLEVELDB_BUILD_TESTS=ON \
        -DLEVELDB_BUILD_BENCHMARKS=OFF
    cmake --build build-test --parallel "$(nproc)"
    ctest --test-dir build-test --output-on-failure
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
