#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : yajl
# Version       : 2.1.0
# Source repo   : https://github.com/lloyd/yajl
# Tested on     : UBI:9.8
# Language      : C
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
#   - C JSON library built with cmake; no Python component upstream
#   - custom_install() builds the library, wraps the installed prefix in a
#   - Upstream licence is COPYING (ISC); LICENSE_FILE tells _copy_license where to find it
#   - Tests run make test against the cmake build tree from the build directory
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="yajl"
PACKAGE_VERSION="${1:-2.1.0}"
PACKAGE_URL="https://github.com/lloyd/yajl"

# OPTIONAL: Build configuration
PROVIDES_ARTIFACT="yajl"
ARTIFACT_VERSION="${PACKAGE_VERSION}"
# upstream licence is COPYING; the helper searches by this name
LICENSE_FILE="COPYING"
LICENSE_SPDX="ISC"

# REQUIRED: Dependencies
RH_DEP_PKGS="cmake"

# CALLBACK: custom_install: replaces the default install step
custom_install() {
    local prefix
    prefix="$(artifact_dir "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}")"

    # Build and install the native library into the artifact prefix
    mkdir -p build
    cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${prefix}"
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
    mkdir -p "${staging}/yajl"

    # Copy the entire installed tree into the package subdirectory
    cp -r "${prefix}/." "${staging}/yajl/"
    rm -f "${staging}/yajl/env.sh" "${staging}/yajl/manifest.json"
    touch "${staging}/yajl/__init__.py"

    # Place the licence inside the package so it ships in the wheel
    _copy_license "${staging}/yajl"

    # Install static packaging files from SCRIPT_DIR (read-only bind-mount)
    sed "s/@VERSION@/${ARTIFACT_VERSION}/" "${SCRIPT_DIR}/setup.py" \
        > "${staging}/setup.py"
    cp "${SCRIPT_DIR}/pyproject.toml" "${staging}/pyproject.toml"
    cp "${SCRIPT_DIR}/MANIFEST.in"    "${staging}/MANIFEST.in"

    # Build the wheel; --no-isolation uses the pre_build venv
    (cd "${staging}" && python -m build --no-isolation --wheel --outdir "${PWD}/../dist")
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    make -C build test
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
