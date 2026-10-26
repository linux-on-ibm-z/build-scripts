#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : zeromq
# Version       : v4.3.5
# Source repo   : https://github.com/zeromq/libzmq
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
#   - ZeroMQ messaging kernel C++ library built with autotools
#   - custom_install() builds the library and wraps the installed prefix in a
#   - Tests run make check against the autotools build
#   - C++ library built with autoconf
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="zeromq"
PACKAGE_VERSION="${1:-v4.3.5}"
PACKAGE_URL="https://github.com/zeromq/libzmq"

# OPTIONAL: Build configuration
PROVIDES_ARTIFACT="zeromq"
ARTIFACT_VERSION="${PACKAGE_VERSION#v}"
ARTIFACT_VERSION="${ARTIFACT_VERSION//_/.}"
LICENSE_SPDX="MPL-2.0"

# REQUIRED: Dependencies
RH_DEP_PKGS="autoconf automake libtool"

# CALLBACK: custom_install: replaces the default install step
custom_install() {
    local prefix
    prefix="$(artifact_dir "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}")"

    ./autogen.sh
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
    mkdir -p "${staging}/zeromq"

    # Copy the entire installed tree into the package subdirectory
    cp -r "${prefix}/." "${staging}/zeromq/"
    rm -f "${staging}/zeromq/env.sh" "${staging}/zeromq/manifest.json"
    touch "${staging}/zeromq/__init__.py"

    # Place the licence inside the package so it ships in the wheel
    _copy_license "${staging}/zeromq"

    # Install static packaging files from SCRIPT_DIR (read-only bind-mount)
    sed "s/@VERSION@/${ARTIFACT_VERSION}/" "${SCRIPT_DIR}/setup.py" \
        > "${staging}/setup.py"
    cp "${SCRIPT_DIR}/pyproject.toml" "${staging}/pyproject.toml"
    cp "${SCRIPT_DIR}/MANIFEST.in"    "${staging}/MANIFEST.in"

    # Build the wheel; python.sh will auditwheel-repair, copy to ${OUTPUT_DIR}, etc.
    (
        cd "${staging}"
        python3 -m build --no-isolation --wheel --outdir "${PWD}/../dist"
    )
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    make check
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
