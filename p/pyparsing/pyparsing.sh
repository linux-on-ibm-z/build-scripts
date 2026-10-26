#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : pyparsing
# Version       : 3.2.3
# Source repo   : https://github.com/pyparsing/pyparsing
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
#   - pyparsing is a pure Python library (PyPI: pyparsing) providing an
#     alternative approach to creating parsers by combining parser elements
#     rather than writing grammar specifications.
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - No mandatory runtime dependencies.
#   - Upstream git tags use a 'v' prefix (e.g., v3.2.3).
#   - Tests: pytest unitTests/ -x -q
#     Expected: majority of tests pass on Python 3.10+.
#   - Tracking issue: LOZPY-TBD
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="pyparsing"
PACKAGE_URL="https://github.com/pyparsing/pyparsing"
NOARCH="true"

# Upstream git tags use a 'v' prefix (e.g., v3.2.3)
PACKAGE_VERSION="${1:-3.2.3}"
# Strip leading 'v' if caller passes v3.2.3 style
PACKAGE_VERSION="${PACKAGE_VERSION#v}"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# Runs the upstream unittest suite via pytest.
# Tests live under unitTests/ in the repo.
# Expected: majority of tests pass on Python 3.10+.
# =============================================================================
custom_test_command() {
    log_info "Installing pyparsing test dependencies..."
    pip install pytest railroad-diagrams
    log_info "Running pyparsing test suite..."
    pytest unitTests/ -x -q
    log_info "pyparsing test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
