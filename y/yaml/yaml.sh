#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : yaml
# Version       : 0.2.5
# Source repo   : https://github.com/yaml/libyaml
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
#     then wraps the prefix in a setuptools shim wheel for consumers
#
# Notes:
#   - LibYAML C library built with autoconf; no Python component upstream
#   - custom_install() bootstraps, builds, installs into the artifact prefix,
#   - License is named "License"; LICENSE_FILE tells _copy_license where to find it
#   - Tests run make test against the autoconf build tree
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="yaml"
PACKAGE_VERSION="${1:-0.2.5}"
PACKAGE_URL="https://github.com/yaml/libyaml"

# OPTIONAL: Build configuration
PROVIDES_ARTIFACT="yaml"
ARTIFACT_VERSION="${PACKAGE_VERSION}"
# upstream licence is named "License"; the helper searches by this name
LICENSE_FILE="License"
LICENSE_SPDX="MIT"

# REQUIRED: Dependencies
RH_DEP_PKGS="automake libtool"

# CALLBACK: custom_install: replaces the default install step
custom_install() {
    local prefix
    prefix="$(artifact_dir "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}")"

    # Bootstrap the autoconf build system
    ./bootstrap

    # Build and install the native library into the artifact prefix
    ./configure --prefix="${prefix}"
    make -j"$(nproc)"
    make install

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
    mkdir -p "${staging}/yaml"

    # Copy the entire installed tree into the package subdirectory
    cp -r "${prefix}/." "${staging}/yaml/"
    rm -f "${staging}/yaml/env.sh" "${staging}/yaml/manifest.json"
    touch "${staging}/yaml/__init__.py"

    # Place the licence inside the package so it ships in the wheel
    _copy_license "${staging}/yaml"

    # Install static packaging files from SCRIPT_DIR (read-only bind-mount)
    sed "s/@VERSION@/${ARTIFACT_VERSION}/" "${SCRIPT_DIR}/setup.py" \
        > "${staging}/setup.py"
    cp "${SCRIPT_DIR}/pyproject.toml" "${staging}/pyproject.toml"
    cp "${SCRIPT_DIR}/MANIFEST.in"    "${staging}/MANIFEST.in"

    # Build the wheel; python.sh's step 9 picks it up from dist/
    cd "${staging}"
    python -m build --no-isolation --wheel --outdir "${PWD}/../dist"
    cd -
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    make test
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
