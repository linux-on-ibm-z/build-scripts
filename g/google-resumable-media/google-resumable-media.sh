#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : google-resumable-media
# Version       : 2.4.0
# Source repo   : https://github.com/googleapis/google-resumable-media-python
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
# PACKAGE_VERSION defaults to v2.4.0, overridable as $1
# =============================================================================
PACKAGE_NAME="google-resumable-media"
PACKAGE_VERSION="${1:-v2.4.0}"
PACKAGE_VERSION="v${PACKAGE_VERSION#v}"
PYPI_VERSION="${PACKAGE_VERSION#v}"
PACKAGE_URL="https://github.com/googleapis/google-resumable-media-python"

# =============================================================================
# OPTIONAL: Build configuration
# =============================================================================
NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# google-resumable-media is pure Python — only needs git + pip tooling
# =============================================================================
RH_DEP_PKGS="git python3-devel python3-pip"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3-devel python3-pip"

# =============================================================================
# OPTIONAL: Pre-test hook
# Installs a Python 3.12-compatible async test runner and test dependencies
# before the test suite runs. pytest-asyncio 0.21.x uses the legacy loop
# fixture which is required by the async unit tests at this version.
# =============================================================================
pre_test() {
    python -m pip install 'pytest<8' 'pytest-asyncio==0.21.2' mock \
        'aiohttp>=3.9,<3.10' requests 'google-auth>=1.22,<3'
}

# =============================================================================
# OPTIONAL: Custom test command
# Runs the sync and async unit suites. No Google Cloud account or service
# credentials are required for the unit tests.
# =============================================================================
custom_test_command() {
    python -m pytest tests/unit tests_async/unit -o "addopts=" -q
}

# =============================================================================
# Source the python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
