#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : parameterized
# Version       : v0.9.0
# Source repo   : https://github.com/wolever/parameterized
# Tested on     : UBI:9.3
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Aritrika Ghosh <aritrika@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
# ==========      platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - parameterized is a pure-Python library
#   - Published noarch wheel installed via NOARCH, not rebuilt from source
#   - No compiled extensions; no extra system packages needed
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# PACKAGE_VERSION defaults to v0.9.0, overridable as $1
# =============================================================================
PACKAGE_NAME="parameterized"
PACKAGE_VERSION="${1:-v0.9.0}"
PACKAGE_URL="https://github.com/wolever/parameterized"

# =============================================================================
# OPTIONAL: Build configuration
# Pure-Python package; install directly from PyPI
# =============================================================================
NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# No extra system packages needed; the container toolchain is sufficient
# =============================================================================
RH_DEP_PKGS=""

# =============================================================================
# Source the python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh" 