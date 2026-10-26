#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : notebook
# Version       : v7.3.3
# Source repo   : https://github.com/jupyter/notebook
# Tested on     : UBI:9.6
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Viddya K <viddya.k@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
# ==========      platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# PACKAGE_VERSION defaults to v7.3.3, overridable as $1
# =============================================================================
PACKAGE_NAME="notebook"
PACKAGE_VERSION="${1:-v7.3.3}"
PACKAGE_URL="https://github.com/jupyter/notebook"

# =============================================================================
# OPTIONAL: Build configuration
# =============================================================================
NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# System packages needed for building notebook
# =============================================================================
RH_DEP_PKGS="git python3-devel python3-pip"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3-devel python3-pip"

# =============================================================================
# OPTIONAL: Build configuration
# =============================================================================
PYPI_VERSION="${PACKAGE_VERSION#v}"

# =============================================================================
# CALLBACK: pre_test
# Installs test prerequisites before the test phase
# =============================================================================
pre_test() {
    python -m pip install "notebook[test]==${PYPI_VERSION}"
}

# =============================================================================
# CALLBACK: custom_test_command
# Replaces the template's default test command
# =============================================================================
custom_test_command() {
    # Run from outside the source tree so pytest imports the installed wheel
    # rather than the local notebook/ directory, which lacks notebook.templates.
    local tests="${PWD}/tests"
    (cd /tmp && python -m pytest "${tests}" --import-mode=importlib \
        -o "addopts=" -W ignore::DeprecationWarning -q)
}

# =============================================================================
# Source the python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
