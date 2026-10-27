#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : bcrypt
# Version       : 5.0.0
# Source repo   : https://github.com/pyca/bcrypt
# Tested on     : UBI:9.3
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Pranjal-Patidar1 <pranjal.patidar1@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
#                 platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="bcrypt"
PACKAGE_VERSION="${1:-5.0.0}"
PACKAGE_URL="https://github.com/pyca/bcrypt"
# NOARCH=true: skip local build, install from PyPI. bcrypt has no s390x wheel
# so pip compiles from sdist; setuptools-rust must be installed first so the
# Rust build backend is available when pip invokes it.
NOARCH="true"

RH_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++ libffi-devel"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv build-essential libffi-dev"
SLES_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++ libffi-devel"

custom_test_command() {
    log_info "Installing Rust build backend..."
    pip install "setuptools-rust>=1.7.0"

    log_info "Installing bcrypt from PyPI (compiles from sdist on s390x)..."
    pip install "bcrypt==${PACKAGE_VERSION}"

    log_info "Running tests..."
    cd /workspace/bcrypt
    pip install pytest
    pytest tests/
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"