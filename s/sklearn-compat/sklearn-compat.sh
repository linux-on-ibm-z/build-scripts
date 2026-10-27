#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : sklearn-compat
# Version       : 0.1.3
# Source repo   : https://github.com/sklearn-compat/sklearn-compat
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
#   - Pure-Python library from sklearn-compat, no compiled extension
#   - Published noarch wheel installed via NOARCH, not rebuilt
#   - No extra system packages needed (container toolchain suffices)
#   - Custom callbacks: custom_test_command
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="sklearn-compat"
PACKAGE_VERSION="${1:-0.1.3}"
PACKAGE_URL="https://github.com/sklearn-compat/sklearn-compat"

# OPTIONAL: Build configuration
# Upstream publishes noarch wheels for every Python in the matrix at 0.1.3,
# so there is nothing to build: python.sh installs the wheel and tests it.
NOARCH="true"

# REQUIRED: Dependencies
RH_DEP_PKGS=""
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    pytest .
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
