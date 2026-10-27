#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : sniffio
# Version       : 1.3.1
# Source repo   : https://github.com/python-trio/sniffio
# Tested on     : UBI:9.6
# Language      : Python
# Ci-Check      : True
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
#   - sniffio detects which async library Python code is running under.
#   - Pure Python wheel — NOARCH=true, installed from PyPI.
#   - Upstream git tags use a 'v' prefix (e.g., v1.3.1).
#   - Tests: pytest sniffio/_tests/ → 4 passed.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="sniffio"
PACKAGE_URL="https://github.com/python-trio/sniffio"
NOARCH="true"

# Upstream git tags are prefixed with 'v' (e.g., v1.3.1)
PACKAGE_VERSION="${1:-1.3.1}"
PACKAGE_VERSION="${PACKAGE_VERSION#v}"
PYPI_VERSION="${PACKAGE_VERSION}"
PACKAGE_VERSION="v${PACKAGE_VERSION}"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# =============================================================================
custom_test_command() {
    log_info "Installing test dependencies and running sniffio test suite..."
    pip install curio pytest-cov
    pytest sniffio/_tests/ -v
    log_info "sniffio test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
