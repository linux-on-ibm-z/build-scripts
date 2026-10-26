#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : gmp
# Version       : 6.3.0
# Source repo   : https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz
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
#   - C/C++ library built with autoconf; produces a native wheel wrapping the prefix
#   - PROVIDES_ARTIFACT so downstream packages can consume via BUILD_DEPS
#   - LICENSE_FILE set because upstream uses COPYING rather than LICENSE
#   - Source is an archive (no upstream Git tag); PACKAGE_VERSION is the release version
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="gmp"
PACKAGE_VERSION="${1:-6.3.0}"
PACKAGE_URL="https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz"

# OPTIONAL: Build configuration
PROVIDES_ARTIFACT="gmp"
ARTIFACT_VERSION="${PACKAGE_VERSION}"
CLONE_DIR="/workspace/${PACKAGE_NAME}"
LICENSE_FILE="COPYING"
LICENSE_SPDX="LGPL-3.0-or-later"

# REQUIRED: Dependencies
RH_DEP_PKGS=""
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# CALLBACK: pre_clone: before the source is cloned
pre_clone() {
    local _archive="${CLONE_DIR}.archive"
    if [[ -s "${_archive}" ]] && ! tar -tf "${_archive}" >/dev/null 2>&1; then
        rm -f "${_archive}"
    fi
    if [[ ! -s "${_archive}" ]]; then
        curl --http1.1 -fSL --retry 5 --retry-all-errors -o "${_archive}" "${PACKAGE_URL}" || return 1
    fi
    rm -rf "${CLONE_DIR}"
    mkdir -p "${CLONE_DIR}"
    tar -xf "${_archive}" --strip-components=1 -C "${CLONE_DIR}" || return 1
    git -C "${CLONE_DIR}" init -q
    git -C "${CLONE_DIR}" add -A
    git -C "${CLONE_DIR}" -c user.email=build@localhost -c user.name=build \
        commit -q -m "${PACKAGE_NAME} ${PACKAGE_VERSION}"
    git -C "${CLONE_DIR}" tag "${PACKAGE_VERSION}"
}

# CALLBACK: custom_install
#   the artifact, then wrap the installed prefix in a setuptools wheel shim.
custom_install() {
    local prefix
    prefix="$(artifact_dir "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}")"

    ./configure --prefix="${prefix}" --enable-cxx
    make -j"$(nproc)"
    make install

    _cleanup_artifact "${prefix}"
    _copy_license "${prefix}"
    _generate_env_sh "${prefix}" "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}"
    generate_artifact_manifest "${prefix}" "${PROVIDES_ARTIFACT}" \
        "${ARTIFACT_VERSION}" "${PACKAGE_URL}" "${LICENSE_SPDX}"

    local staging="${SCRIPT_DIR}/staging"
    rm -rf "${staging}"
    mkdir -p "${staging}"
    cp -a "${prefix}" "${staging}/${PACKAGE_NAME}"
    touch "${staging}/${PACKAGE_NAME}/__init__.py"

    sed "s/@VERSION@/${ARTIFACT_VERSION}/" "${SCRIPT_DIR}/setup.py" \
        > "${staging}/setup.py"
    cp "${SCRIPT_DIR}/pyproject.toml" "${staging}/pyproject.toml"
    cp "${SCRIPT_DIR}/MANIFEST.in"   "${staging}/MANIFEST.in"

    python -m build --wheel --no-isolation --outdir "${SCRIPT_DIR}/dist" "${staging}"
    cp "${SCRIPT_DIR}/dist/"*.whl "${OUTPUT_DIR}/"
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    make check
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
