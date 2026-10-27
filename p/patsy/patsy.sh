#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : patsy
# Version       : v1.0.1
# Source repo   : https://github.com/pydata/patsy
# Tested on     : UBI:9.6
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
#   - numpy and scipy (test extra) are fetched from PyPI by the template
#   - Pure-Python library from pydata, no compiled extension
#   - Published noarch wheel installed via NOARCH, not rebuilt
#   - No extra system packages needed (container toolchain suffices)
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# PACKAGE_VERSION defaults to v1.0.1, overridable as $1
# =============================================================================
PACKAGE_NAME="patsy"
PACKAGE_VERSION="${1:-v1.0.1}"
PACKAGE_URL="https://github.com/pydata/patsy"

# =============================================================================
# OPTIONAL: Build configuration
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
