#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : mpc
# Version       : 1.4.1
# Source repo   : https://gitlab.inria.fr/mpc/mpc.git
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
#     installed prefix in a setuptools shim, and publishes the artifact
#     pre-generated configure script
#
# Notes:
#   - GNU MPC complex floating-point C library; no Python component upstream
#   - custom_install() runs autoreconf, builds with autoconf, wraps the
#   - autoconf/automake/libtool required: source has configure.ac, no
#   - Depends on GMP (gmp-devel) and MPFR (mpfr-devel) system packages
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="mpc"
PACKAGE_VERSION="${1:-1.4.1}"
PACKAGE_URL="https://gitlab.inria.fr/mpc/mpc.git"

# OPTIONAL: Build configuration
PROVIDES_ARTIFACT="mpc"
ARTIFACT_VERSION="${PACKAGE_VERSION}"
# upstream licence filename; _copy_license searches by this name
LICENSE_FILE="COPYING.LESSER"
LICENSE_SPDX="LGPL-3.0-or-later"

# REQUIRED: Dependencies
# autoconf/automake/libtool: needed because the source ships configure.ac only
# gmp-devel/mpfr-devel: required by configure.ac (checked via AC_CHECK_LIB)
# texinfo not listed: not in any enabled UBI9 repo; makeinfo is only needed
# for doc/mpc.info which is not built or tested by make -C build/tests check
RH_DEP_PKGS="autoconf automake gmp-devel libtool mpfr-devel"

# CALLBACK: custom_install: replaces the default install step
custom_install() {
    local prefix
    prefix="$(artifact_dir "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}")"

    # Generate the configure script from configure.ac
    autoreconf -fi

    # Build and install the native library into the artifact prefix
    ./configure \
        --prefix="${prefix}" \
        --enable-shared \
        --disable-static || return 1
    make -j"$(nproc)" SUBDIRS="src" || return 1
    make install SUBDIRS="src" || return 1

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
    mkdir -p "${staging}/mpc"

    # Copy the entire installed tree into the package subdirectory
    cp -r "${prefix}/." "${staging}/mpc/"
    rm -f "${staging}/mpc/env.sh" "${staging}/mpc/manifest.json"
    touch "${staging}/mpc/__init__.py"

    # Place the licence inside the package so it ships in the wheel
    _copy_license "${staging}/mpc"

    # Install static packaging files from SCRIPT_DIR (read-only bind-mount)
    sed "s/@VERSION@/${ARTIFACT_VERSION}/" "${SCRIPT_DIR}/setup.py" \
        > "${staging}/setup.py"
    cp "${SCRIPT_DIR}/pyproject.toml" "${staging}/pyproject.toml"
    cp "${SCRIPT_DIR}/MANIFEST.in"    "${staging}/MANIFEST.in"

    # Build the wheel and place it where python.sh step 9 will find it
    # Use an absolute path so the linter can confirm the wheel lands in dist/
    local dist_dir="${PWD}/dist"
    mkdir -p "${dist_dir}"
    cd "${staging}"
    python -m build --no-isolation --wheel --outdir "${dist_dir}"
    cd ..
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    # Scope check to tests/ only: doc/ requires makeinfo (texinfo) which is
    # unavailable in any enabled UBI9 repo; all 75 library tests live in tests/.
    make -C tests check
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
