#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : pyopenssl
# Version       : 25.0.0
# Source repo   : https://github.com/pyca/pyopenssl
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
#   - pyOpenSSL is a Python wrapper around a subset of the OpenSSL library
#     (PyPI: pyOpenSSL). It exposes high-level TLS/SSL operations via
#     Python bindings built on top of the cryptography package.
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - Runtime deps: cryptography>=41.0.0.
#   - Upstream git tags have no 'v' prefix (e.g., 25.0.0).
#   - Tests: pytest tests/ -x -q
#     Expected: majority of tests pass on Python 3.10+.
#   - Tracking issue: LOZPY-TBD
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="pyopenssl"
PACKAGE_URL="https://github.com/pyca/pyopenssl"
NOARCH="true"
PYPI_NAME="pyOpenSSL"

# Upstream git tags have no 'v' prefix (e.g., 25.0.0)
PACKAGE_VERSION="${1:-25.0.0}"
# Strip leading 'v' if caller passes v25.0.0 style
PACKAGE_VERSION="${PACKAGE_VERSION#v}"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip openssl-devel"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv libssl-dev"
SLES_DEP_PKGS="git python3 python3-devel python3-pip libopenssl-devel"

# =============================================================================
# CALLBACK: custom_test_command
# Installs test dependencies and runs the pyOpenSSL test suite.
# cryptography is a mandatory runtime dep; pretend and flaky are test helpers.
# Expected: majority of tests pass on Python 3.10+.
# =============================================================================
custom_test_command() {
    log_info "Installing pyOpenSSL test dependencies..."
    pip install pytest pytest-rerunfailures \
        "cryptography>=41.0.0" \
        pretend flaky
    log_info "Running pyOpenSSL test suite..."
    pytest tests/ -x -q
    log_info "pyOpenSSL test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
