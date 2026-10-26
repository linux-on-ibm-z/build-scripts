#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : virtualenv
# Version       : 20.30.0
# Source repo   : https://github.com/pypa/virtualenv
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
#   - virtualenv is a pure Python tool (PyPI: virtualenv) for creating
#     isolated Python environments. It is a superset of venv with support
#     for older Python versions and additional seed package control.
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - Runtime deps: distlib>=0.3.7, filelock>=3.12.2, platformdirs>=3.9.1.
#   - Upstream git tags have no 'v' prefix (e.g., 20.30.0).
#   - Tests: pytest tests/ -x -q.
#     Tests that spin up child virtualenv processes require a writable
#     temp directory and a working pip index; network-dependent tests are
#     gated by a skip marker in the upstream suite and are skipped in CI.
#   - Tracking issue: LOZPY-TBD
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="virtualenv"
PACKAGE_URL="https://github.com/pypa/virtualenv"
NOARCH="true"

# Upstream git tags have no 'v' prefix (e.g., 20.30.0)
PACKAGE_VERSION="${1:-20.30.0}"
# Strip leading 'v' if caller passes v20.30.0 style
PACKAGE_VERSION="${PACKAGE_VERSION#v}"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# Installs runtime and test dependencies then runs the virtualenv test suite.
# pytest-mock and pytest-timeout are used by the upstream suite.
# Tests that require a live pip index or network access are gated by
# upstream skip markers and are automatically skipped in CI environments.
# Expected: majority of tests pass on Python 3.10+ on UBI.
# =============================================================================
custom_test_command() {
    log_info "Installing virtualenv test dependencies..."
    pip install pytest pytest-mock pytest-timeout \
        "distlib>=0.3.7" "filelock>=3.12.2" "platformdirs>=3.9.1"
    log_info "Running virtualenv test suite..."
    pytest tests/ -x -q
    log_info "virtualenv test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
