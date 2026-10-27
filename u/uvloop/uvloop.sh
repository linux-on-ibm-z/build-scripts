#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : uvloop
# Version       : v0.19.0
# Source repo   : https://github.com/MagicStack/uvloop
# Tested on     : UBI:9.8
# Language      : Python
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
#   - Bundles libuv as a git submodule; setup.py builds it via autotools
#   - Cython 0.29.x (upstream pin) required at build time (--no-isolation; no loop.c in checkout)
#   - Cython-based Python library from MagicStack
#   - Cython extensions compiled from 23 .pyx sources
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="uvloop"
PACKAGE_VERSION="${1:-v0.19.0}"
PACKAGE_URL="https://github.com/MagicStack/uvloop"

# REQUIRED: Dependencies
RH_DEP_PKGS="autoconf automake libtool"
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# CALLBACK: post_clone: after the clone, worktree at PACKAGE_VERSION
post_clone() {
    # https://github.com/MagicStack/uvloop/pull/614/changes
    # https://github.com/MagicStack/uvloop/commit/56807922f847ddac231a53d5b03eef70092b987c
    if [[ -f "${SCRIPT_DIR}/patches/${PACKAGE_NAME}.patch" ]]; then
        log_info "Applying generated patch..."
        git apply "${SCRIPT_DIR}/patches/${PACKAGE_NAME}.patch"
    fi
}

# CALLBACK: pre_build: in the build env, before the build
pre_build() {
    # Cython==0.29.37 satisfies upstream's own pin Cython(>=0.29.36,<0.30.0)
    pip install "setuptools>=60" "wheel" "Cython==0.29.37"
}

# CALLBACK: pre_test: installs test prerequisites
pre_test() {
    # --no-cache-dir: cryptography's source-built wheel failed to land in the shared
    # /workspace/.pip-cache (FileNotFoundError on its tmp dir), killing pre_test.
    pip install --no-cache-dir "psutil" "pyOpenSSL" || return 1
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    ( _tests="${PWD}/tests"; cd "${HOME}" && pytest "${_tests}" )
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
