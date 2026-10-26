#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : flit-core
# Version       : 3.12.0
# Source repo   : https://github.com/pypa/flit
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
#   - flit-core is the build backend for the Flit packaging tool. It provides
#     the essential functionality required to build Python packages and is a
#     PEP 517 build backend.
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - No runtime dependencies.
#   - The flit monorepo hosts flit-core under the flit_core/ subdirectory.
#     PyPI package name is 'flit_core'; PYPI_NAME is set accordingly.
#   - Upstream git tags have no 'v' prefix (e.g., 3.12.0).
#   - Tests live at flit_core/tests_core/test_*.py (two levels deep). The
#     template's default pytest glob (*/test_*.py, tests/test_*.py) does not
#     discover them; custom_test_command() runs pytest from the flit_core/
#     subdirectory where pyproject.toml configures pytest correctly.
#   - No extra test deps required — flit_core has no runtime or test
#     dependencies beyond pytest.
#   - Expected: 210 passed, 1 skipped on Python 3.12.
#   - Tracking issue: LOZPY-171
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="flit-core"
PACKAGE_URL="https://github.com/pypa/flit"
NOARCH="true"
# PyPI package name uses underscore
PYPI_NAME="flit_core"

# Upstream git tags have no 'v' prefix (e.g., 3.12.0)
PACKAGE_VERSION="${1:-3.12.0}"
# Strip leading 'v' if caller passes v3.12.0 style
PACKAGE_VERSION="${PACKAGE_VERSION#v}"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# flit-core tests live at flit_core/tests_core/test_*.py inside the monorepo.
# pytest must be run from the flit_core/ subdirectory so that its pyproject.toml
# (which configures the testpaths) is picked up correctly.
# No extra test deps are required — flit_core has no dependencies.
# Expected: 210 passed, 1 skipped on Python 3.12.
# =============================================================================
custom_test_command() {
    log_info "Running flit-core test suite..."
    cd flit_core
    pytest tests_core/ -v
    cd ..
    log_info "flit-core test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
