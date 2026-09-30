#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : frozenlist
# Version       : v1.6.0
# Source repo   : https://github.com/aio-libs/frozenlist
# Tested on     : UBI:9.6
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Build Scripts Team <build-scripts@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
# ==========      platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - Cython-based Python library from aio-libs
#   - Built by the in-tree PEP 517 backend under packaging/
#   - Cython extensions compiled from frozenlist/_frozenlist.pyx
#   - Published s390x wheel installed via NOARCH, not rebuilt
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# PACKAGE_VERSION defaults to v1.6.0, overridable as $1
# =============================================================================
PACKAGE_NAME="frozenlist"
PACKAGE_VERSION="${1:-v1.6.0}"
PACKAGE_URL="https://github.com/aio-libs/frozenlist"

# =============================================================================
# OPTIONAL: Build configuration
# =============================================================================
# Upstream publishes s390x wheels for every Python in the matrix at 1.6.0,
# so there is nothing to build: python.sh installs the wheel and tests it.
NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# No extra system packages needed; the container toolchain is sufficient
# =============================================================================
RH_DEP_PKGS=""
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# =============================================================================
# Source the python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../templates/python.sh"
