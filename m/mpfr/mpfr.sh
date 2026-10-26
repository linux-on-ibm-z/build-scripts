#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : mpfr
# Version       : 4.1.0
# Source repo   : https://gitlab.inria.fr/mpfr/mpfr
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
#   - GNU MPFR arbitrary-precision floating-point library built with autoconf
#   - Requires GMP; the template sources its env.sh via BUILD_DEPS="gmp"
#   - custom_install() builds the library, wraps the installed prefix in a
#   - License is COPYING.LESSER (LGPL-3.0-or-later)
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="mpfr"
PACKAGE_VERSION="${1:-4.1.0}"
PACKAGE_URL="https://gitlab.inria.fr/mpfr/mpfr"

# OPTIONAL: Build configuration
PROVIDES_ARTIFACT="mpfr"
ARTIFACT_VERSION="${PACKAGE_VERSION}"
# gmp supplies GMP_PREFIX for --with-gmp
BUILD_DEPS="gmp"
# upstream licence is COPYING.LESSER; the helper searches by this name
LICENSE_FILE="COPYING.LESSER"
LICENSE_SPDX="LGPL-3.0-or-later"

# REQUIRED: Dependencies
# automake provides aclocal, autoconf-archive provides AX_PTHREAD, libtool provides libtoolize
RH_DEP_PKGS="autoconf-archive automake libtool"

# CALLBACK: custom_install: replaces the default install step
custom_install() {
    local prefix
    prefix="$(artifact_dir "${PROVIDES_ARTIFACT}" "${ARTIFACT_VERSION}")"

    # Build and install the native library into the artifact prefix.
    # GMP_PREFIX is exported by the template after sourcing gmp's env.sh
    # (via BUILD_DEPS="gmp" in build_info.json).
    ./autogen.sh
    # texinfo is not in any enabled repository; MAKEINFO=true on the make
    # command line turns the mpfr.info documentation step into a no-op.
    ./configure --prefix="${prefix}" --with-gmp="${GMP_PREFIX}"
    make -j"$(nproc)" MAKEINFO=true
    make install MAKEINFO=true

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
    mkdir -p "${staging}/mpfr"

    # Copy the entire installed tree into the package subdirectory
    cp -r "${prefix}/." "${staging}/mpfr/"
    rm -f "${staging}/mpfr/env.sh" "${staging}/mpfr/manifest.json"
    touch "${staging}/mpfr/__init__.py"

    # Place the licence inside the package so it ships in the wheel
    _copy_license "${staging}/mpfr"

    # Install static packaging files from SCRIPT_DIR (read-only bind-mount)
    sed "s/@VERSION@/${ARTIFACT_VERSION}/" "${SCRIPT_DIR}/setup.py" \
        > "${staging}/setup.py"
    cp "${SCRIPT_DIR}/pyproject.toml" "${staging}/pyproject.toml"
    cp "${SCRIPT_DIR}/MANIFEST.in"    "${staging}/MANIFEST.in"

    # Build the wheel; python -m build honours --no-isolation
    python -m build --no-isolation --wheel --outdir "${PWD}/dist" "${staging}"
}

# CALLBACK: pre_test
#   ${OUTPUT_DIR} install runs; the batch install can fail if a sibling wheel
# (e.g. seaborn) is listed but absent, which would otherwise block make check.
pre_test() {
    pip install --no-index --find-links "${OUTPUT_DIR}" "mpfr==${ARTIFACT_VERSION}"
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    make check MAKEINFO=true
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
