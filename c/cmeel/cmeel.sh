#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : cmeel
# Version       : v0.57.3
# Source repo   : https://github.com/cmake-wheel/cmeel
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
# PACKAGE_VERSION defaults to v0.57.3, overridable as $1
# =============================================================================
PACKAGE_NAME="cmeel"
PACKAGE_VERSION="${1:-v0.57.3}"
PACKAGE_URL="https://github.com/cmake-wheel/cmeel"

# =============================================================================
# OPTIONAL: Build configuration
# =============================================================================
NOARCH="true"
SKIP_TESTS="true"  # upstream provides no test suite

# =============================================================================
# REQUIRED: Dependencies
# System packages needed for building cmeel
# =============================================================================
# cmeel is pure Python — only needs git + pip tooling
RH_DEP_PKGS="git python3-devel python3-pip"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3-devel python3-pip"

# =============================================================================
# Source the python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
