#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : gmpy
# Version       : v2.2.1
# Source repo   : https://github.com/aleaxit/gmpy
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
#   - C extension wrapping GMP, MPFR and MPC for arbitrary-precision arithmetic
#   - Requires system-level development libraries gmp-devel, mpfr-devel, libmpc-devel
#   - setuptools>=61 required by pyproject.toml; bounded <70 via SETUPTOOLS_VERSION
#   - Cython-based Python library from aleaxit
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="gmpy"
PACKAGE_VERSION="${1:-v2.2.1}"
PACKAGE_URL="https://github.com/aleaxit/gmpy"

# REQUIRED: Dependencies
RH_DEP_PKGS="gmp-devel libmpc-devel mpfr-devel"
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# OPTIONAL: Build configuration
# setuptools must satisfy pyproject.toml's requires = ['setuptools>=61']
SETUPTOOLS_VERSION=">=61,<70"

# CALLBACK: post_clone: after the clone, worktree at PACKAGE_VERSION
post_clone() {
    if [[ -n "${PYTHON_VERSION}" && " 3.13 3.14 " == *" ${PYTHON_VERSION} "* && -f "${SCRIPT_DIR}/patches/gmpy-py3.13-3.14.patch" ]]; then
        log_info "Applying py3.13, py3.14 patch..."
        git apply "${SCRIPT_DIR}/patches/gmpy-py3.13-3.14.patch"
    fi
}

# CALLBACK: pre_test: installs test prerequisites
pre_test() {
    pip install psutil hypothesis
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    pytest test/
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
