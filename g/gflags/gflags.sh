#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : gflags
# Version       : v2.2.2
# Source repo   : https://github.com/gflags/gflags
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
#   - C++ commandline flags library built with cmake; no Python component upstream
#   - custom_install() builds the library, wraps the installed prefix in a
#   - License is COPYING.txt; LICENSE_FILE tells _copy_license where to find it
#   - C++ library built with cmake
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="gflags"
PACKAGE_VERSION="${1:-v2.2.2}"
PACKAGE_URL="https://github.com/gflags/gflags"

# OPTIONAL: Build configuration
PROVIDES_ARTIFACT="gflags"
ARTIFACT_VERSION="${PACKAGE_VERSION#v}"
# upstream licence is COPYING.txt; the helper searches by this name
LICENSE_FILE="COPYING.txt"
LICENSE_SPDX="BSD-3-Clause"

# REQUIRED: Dependencies
RH_DEP_PKGS="cmake"

# CALLBACK: custom_install: replaces the default install step
custom_install() {
    local prefix
    prefix="$(artifact_dir "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}")"

    # Build and install the native library into the artifact prefix
    mkdir -p build
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${prefix}" \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_STATIC_LIBS=ON \
        -DINSTALL_HEADERS=ON \
        -DBUILD_TESTING=ON
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
    mkdir -p "${staging}/gflags"

    # Copy installed tree into the package subdirectory
    cp -r "${prefix}/lib"     "${staging}/gflags/lib"
    cp -r "${prefix}/include" "${staging}/gflags/include"
    touch "${staging}/gflags/__init__.py"

    # Place the licence inside the package so it ships in the wheel
    _copy_license "${staging}/gflags"

    # Install static packaging files from SCRIPT_DIR (read-only bind-mount)
    sed "s/@VERSION@/${ARTIFACT_VERSION}/" "${SCRIPT_DIR}/setup.py" \
        > "${staging}/setup.py"
    cp "${SCRIPT_DIR}/pyproject.toml" "${staging}/pyproject.toml"
    cp "${SCRIPT_DIR}/MANIFEST.in"    "${staging}/MANIFEST.in"

    # Build the wheel; python -m build honours --no-isolation
    python -m build --no-isolation --wheel --outdir "${PWD}/dist" "${staging}"
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    cmake --build build --target test --parallel "$(nproc)"
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
