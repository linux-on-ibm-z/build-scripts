#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : idna
# Version       : 3.1
# Source repo   : https://github.com/kjd/idna
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
#   - idna is a pure Python library implementing the Internationalized Domain
#     Names in Applications (IDNA) protocol as specified in RFC 5891
#     (PyPI: idna). It is widely used as a dependency for urllib3, requests,
#     and other networking libraries.
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - Upstream git tags use a 'v' prefix (e.g., v3.1).
#   - Tests: pytest tests/ → all passed on Python 3.10+.
#   - Tracking issue: LOZPY-TBD
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="idna"
PACKAGE_URL="https://github.com/kjd/idna"
NOARCH="true"

# Upstream git tags use a 'v' prefix (e.g., v3.1)
PACKAGE_VERSION="${1:-3.1}"

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
# Runs the upstream pytest suite.
# Expected: all passed on Python 3.10+.
# =============================================================================
custom_test_command() {
    pip install pytest
    python -m pytest tests/ -v
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
