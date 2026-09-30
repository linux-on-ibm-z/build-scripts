#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : google-api-core
# Version       : v2.10.1
# Source repo   : https://github.com/googleapis/python-api-core
# Tested on     : UBI:9.3
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Pranjal-Patidar1 <pranjal.patidar1@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on the given
#                 platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact the "Maintainer" of this script.
#
# Notes:
#   - google-api-core provides common helpers for Google API clients.
#   - The package is a pure Python package.
#   - The package is marked as NOARCH and is installed from PyPI.
#   - No custom build command is required for this NOARCH package.
#   - Test dependencies are installed before the template test workflow.
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="google-api-core"
PACKAGE_VERSION="${1:-v2.10.1}"
PACKAGE_URL="https://github.com/googleapis/python-api-core"

NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel"
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# =============================================================================
# CALLBACK: Pre-test
# Install dependencies required for running the test suite.
# =============================================================================
pre_test() {
    log_info "Installing test dependencies..."

    pip install --upgrade \
        "pytest<9" \
        pytest-asyncio \
        mock \
        proto-plus \
        protobuf \
        google-auth \
        googleapis-common-protos \
        requests
}

# =============================================================================
# Execute the build (invokes the Python template)
# =============================================================================
source "${SCRIPT_DIR}/../../templates/python.sh"