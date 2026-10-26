#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : marshmallow
# Version       : 3.21.3
# Source repo   : https://github.com/marshmallow-code/marshmallow
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
# PACKAGE_VERSION defaults to 3.21.3, overridable as $1
# =============================================================================
PACKAGE_NAME="marshmallow"
PACKAGE_VERSION="${1:-3.21.3}"
PACKAGE_URL="https://github.com/marshmallow-code/marshmallow"

# =============================================================================
# OPTIONAL: Build configuration
# =============================================================================
# Verified against the exact PyPI release; see README.md.
NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# System packages needed for building marshmallow
# =============================================================================
RH_DEP_PKGS="git python3-devel python3-pip"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3-devel python3-pip"

# =============================================================================
# OPTIONAL: Build configuration
# =============================================================================
PYPI_VERSION="${PACKAGE_VERSION}"

# =============================================================================
# CALLBACK: pre_test
# Installs test prerequisites before the test phase
# =============================================================================
pre_test() {
    python -m pip install pytz simplejson
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"
