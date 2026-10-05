#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : cachetools
# Version       : v7.1.4
# Source repo   : https://github.com/tkem/cachetools.git
# Tested on     : UBI:9.6
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Sudip Roy <Sudip.Roy2@ibm.com>
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="cachetools"
PACKAGE_VERSION="${1:-v7.1.4}"
PACKAGE_URL="https://github.com/tkem/cachetools.git"
NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel"
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# Custom test command
custom_test_command() {
    if ! tox -e py3; then
        echo "------------------${PACKAGE_NAME}:Test_fails-------------------------------------"
        return 1
    fi
}

# =============================================================================
# Execute the build (invokes the Python template)
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
