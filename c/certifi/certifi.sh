#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : certifi
# Version       : 2025.01.31
# Source repo   : https://github.com/certifi/python-certifi
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
#
# Notes:
#   - certifi is a pure Python package (no C extensions)
#   - Provides Mozilla's curated CA bundle for SSL certificate validation
#   - Repository name is python-certifi; pip package name is certifi
#   - Version tags are plain date strings (e.g. 2025.01.31), no 'v' prefix
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="certifi"
PACKAGE_VERSION="${1:-2025.01.31}"
PACKAGE_URL="https://github.com/certifi/python-certifi"
NOARCH="true"

# The GitHub repo is named python-certifi; the template clones into a dir
# derived from the URL basename, so we set CLONE_DIR explicitly.
CLONE_DIR="python-certifi"

# =============================================================================
# REQUIRED: Dependencies
# certifi is pure Python — only needs git + pip tooling
# =============================================================================
RH_DEP_PKGS="git python3-devel python3-pip"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# Run the certifi test suite with pytest
# =============================================================================
custom_test_command() {
    log_info "Installing test dependencies..."
    pip install pytest || true

    log_info "Running pytest..."
    pytest --disable-warnings
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
