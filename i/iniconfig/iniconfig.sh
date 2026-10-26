#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : iniconfig
# Version       : 2.1.0
# Source repo   : https://github.com/pytest-dev/iniconfig
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
#   - iniconfig is a small and simple INI-file parser library for Python
#     (PyPI: iniconfig), used primarily as a dependency of pytest to parse
#     its configuration files (pytest.ini, tox.ini, setup.cfg).
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - Upstream git tags use a 'v' prefix (e.g., v2.1.0).
#   - Tests: pytest testing/ → all passed on Python 3.10+.
#   - Tracking issue: LOZPY-TBD
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="iniconfig"
PACKAGE_URL="https://github.com/pytest-dev/iniconfig"
NOARCH="true"

# Upstream git tags use a 'v' prefix (e.g., v2.1.0)
PACKAGE_VERSION="${1:-2.1.0}"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: pre_clone
# Ensure PACKAGE_VERSION always carries the 'v' prefix required by the
# upstream tag format before the repository is cloned and checked out.
# =============================================================================
pre_clone() {
    if [[ "${PACKAGE_VERSION}" != v* ]]; then
        PACKAGE_VERSION="v${PACKAGE_VERSION}"
    fi
}

# =============================================================================
# CALLBACK: custom_test_command
# Runs the upstream pytest suite located in the testing/ directory.
# Expected: all passed on Python 3.10+.
# =============================================================================
custom_test_command() {
    pip install pytest
    python -m pytest testing/ -v
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
