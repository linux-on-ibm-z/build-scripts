#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : pygments
# Version       : 2.19.1
# Source repo   : https://github.com/pygments/pygments
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
#   - Pygments is a pure Python syntax highlighting library (PyPI: Pygments)
#     supporting hundreds of languages and output formats.
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - No mandatory runtime dependencies.
#   - Upstream git tags have no 'v' prefix (e.g., 2.19.1).
#   - Tests: pytest tests/ -x -q
#     Expected: majority of tests pass on Python 3.10+.
#   - Tracking issue: LOZPY-TBD
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="pygments"
PACKAGE_URL="https://github.com/pygments/pygments"
NOARCH="true"
PYPI_NAME="Pygments"

# Upstream git tags have no 'v' prefix (e.g., 2.19.1)
PACKAGE_VERSION="${1:-2.19.1}"
# Strip leading 'v' if caller passes v2.19.1 style
PACKAGE_VERSION="${PACKAGE_VERSION#v}"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# Runs the upstream pytest suite.
# Expected: majority of tests pass on Python 3.10+.
# =============================================================================
custom_test_command() {
    log_info "Installing pygments test dependencies..."
    pip install pytest wcag-contrast-ratio
    log_info "Running pygments test suite..."
    pytest tests/ -x -q
    log_info "pygments test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
