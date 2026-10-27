#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : bzip2
# Version       : bzip2-1.0.8
# Source repo   : https://gitlab.com/bzip2/bzip2
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
#     a setuptools shim so the wheel ships all shared objects and headers
#
# Notes:
#   - C library built with make; Makefile-libbz2_so produces the shared object
#   - custom_install() builds, publishes the artifact, and wraps the prefix in
#   - C library built with make
#   - Compiled extension makes the wheel architecture-specific
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="bzip2"
PACKAGE_VERSION="${1:-bzip2-1.0.8}"
PACKAGE_URL="https://gitlab.com/bzip2/bzip2"

# OPTIONAL: Build configuration
PROVIDES_ARTIFACT="bzip2"
ARTIFACT_VERSION="${PACKAGE_VERSION#bzip2-}"
LICENSE_SPDX="bzip2-1.0"

# REQUIRED: Dependencies
RH_DEP_PKGS=""

# CALLBACK: custom_install
#   and wrap the installed prefix in a setuptools wheel shim
custom_install() {
    local prefix
    prefix="$(artifact_dir "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}")"

    # Build the shared library first, then the static library and tools
    make -f Makefile-libbz2_so
    make -j"$(nproc)"
    make PREFIX="${prefix}" install

    # Copy the versioned shared object and create the expected symlinks
    cp libbz2.so* "${prefix}/lib/"
    ( cd "${prefix}/lib"
      ln -sf "libbz2.so.${ARTIFACT_VERSION}" libbz2.so.1.0
      ln -sf "libbz2.so.${ARTIFACT_VERSION}" libbz2.so.1
      ln -sf "libbz2.so.${ARTIFACT_VERSION}" libbz2.so
    )

    # Publish the artifact for downstream consumers
    _cleanup_artifact "${prefix}"
    _copy_license "${prefix}"
    _generate_env_sh "${prefix}" "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}"
    generate_artifact_manifest "${prefix}" "${PROVIDES_ARTIFACT}" \
        "${ARTIFACT_VERSION}" "${PACKAGE_URL}" "${LICENSE_SPDX}"

    # Wrap the installed prefix in a setuptools shim so the wheel ships
    # the shared objects, headers, and binaries alongside the package marker
    local staging="${PWD}/staging"
    rm -rf "${staging}"
    mkdir -p "${staging}/bzip2"

    cp -r "${prefix}/." "${staging}/bzip2/"
    rm -f "${staging}/bzip2/env.sh" "${staging}/bzip2/manifest.json"
    touch "${staging}/bzip2/__init__.py"

    # Place the licence inside the package so it ships in the wheel
    _copy_license "${staging}/bzip2"

    # Install static packaging files from SCRIPT_DIR (read-only bind-mount)
    sed "s/@VERSION@/${ARTIFACT_VERSION}/" "${SCRIPT_DIR}/setup.py" \
        > "${staging}/setup.py"
    cp "${SCRIPT_DIR}/pyproject.toml" "${staging}/pyproject.toml"
    cp "${SCRIPT_DIR}/MANIFEST.in"    "${staging}/MANIFEST.in"

    # Build the wheel into dist/ so python.sh step 9 picks it up
    ( cd "${staging}" && python -m build --no-isolation --wheel --outdir "${PWD}/../dist" )
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    make test
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
