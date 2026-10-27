#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : markupsafe
# Version       : 3.0.2
# Source repo   : https://github.com/pallets/markupsafe
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
# PACKAGE_VERSION defaults to 3.0.2, overridable as $1
# =============================================================================
PACKAGE_NAME="markupsafe"
PACKAGE_VERSION="${1:-3.0.2}"
PACKAGE_URL="https://github.com/pallets/markupsafe"

# =============================================================================
# REQUIRED: Dependencies
# System packages needed for building markupsafe
# =============================================================================
RH_DEP_PKGS="gcc git python3-devel python3-pip"
DEB_DEP_PKGS="gcc git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="gcc git python3-devel python3-pip"

# =============================================================================
# OPTIONAL: Build configuration
# =============================================================================
PYPI_VERSION="${PACKAGE_VERSION}"
# Upstream requires setuptools>=70.1; override the template's <70 default.
SETUPTOOLS_VERSION=">=70.1,<82"

# =============================================================================
# CALLBACK: custom_test_command
# Replaces the template's default test command
# =============================================================================
custom_test_command() {
    python -c 'import markupsafe._speedups' || return $?
    python -m pytest tests --import-mode=importlib -o "addopts=" -q
}

# Fail compilation rather than silently falling back to a pure-Python wheel.
export CIBUILDWHEEL=1

# =============================================================================
# Source the python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
