#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : jinja2
# Version       : 3.1.6
# Source repo   : https://github.com/pallets/jinja
# Tested on     : UBI:9.3
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Pranjal-Patidar1 <pranjal.patidar1@ibm.com>
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="jinja2"
PACKAGE_VERSION="${1:-3.1.6}"
PACKAGE_URL="https://github.com/pallets/jinja"

NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3-devel python3-pip"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# Install required test dependencies and run the test suite.
# =============================================================================
custom_test_command() {
    log_info "Installing test dependencies..."

    pip install --upgrade \
        "pytest<9" \
        trio

    log_info "Running tests..."

    set -o pipefail

    pytest \
        --deselect=tests/test_core_tags.py::TestIfCondition::test_elif_deep \
        | tee test_logs.txt
}

# =============================================================================
# Source the Python template to execute the build and test workflow
# =============================================================================
source "${SCRIPT_DIR}/../../templates/python.sh"