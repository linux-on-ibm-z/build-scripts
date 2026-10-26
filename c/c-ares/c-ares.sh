#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : c-ares
# Version       : cares-1_19_1
# Source repo   : https://github.com/c-ares/c-ares
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
#   - Asynchronous DNS C library built with cmake; no Python component upstream
#   - custom_install() builds the library, wraps the installed prefix in a
#   - License is LICENSE.md; LICENSE_FILE tells _copy_license where to find it
#   - Tests run make test against the cmake build tree with CARES_BUILD_TESTS=ON
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="c-ares"
PACKAGE_VERSION="${1:-cares-1_19_1}"
PACKAGE_URL="https://github.com/c-ares/c-ares"

# OPTIONAL: Build configuration
PROVIDES_ARTIFACT="c-ares"
ARTIFACT_VERSION="${PACKAGE_VERSION#cares-}"
ARTIFACT_VERSION="${ARTIFACT_VERSION//_/.}"
# upstream licence is LICENSE.md; the helper searches by this name
LICENSE_FILE="LICENSE.md"
LICENSE_SPDX="MIT"

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
        -DCMAKE_INSTALL_PREFIX="${prefix}" \
        -DCARES_SHARED=ON \
        -DCARES_STATIC=ON \
        -DCARES_STATIC_PIC=ON \
        -DCARES_BUILD_TESTS=ON \
        -DCARES_BUILD_TOOLS=ON
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
    mkdir -p "${staging}/c_ares"

    # Copy the entire installed tree into the package subdirectory
    cp -r "${prefix}/." "${staging}/c_ares/"
    rm -f "${staging}/c_ares/env.sh" "${staging}/c_ares/manifest.json"
    touch "${staging}/c_ares/__init__.py"

    # Place the licence inside the package so it ships in the wheel
    _copy_license "${staging}/c_ares"

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
    # Verify the library is importable via pkg-config from the artifact prefix
    pkg-config --modversion libcares
    # Run the upstream test suite built in the cmake build tree
    make -C build test
}

# auditwheel repair runs in the main shell after custom_install() returns;
# the subshell export would be lost, so set it here at the top level.
export LD_LIBRARY_PATH="${ARTIFACT_WORKSPACE}/c-ares/${ARTIFACT_VERSION}/lib64:${LD_LIBRARY_PATH}"

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
