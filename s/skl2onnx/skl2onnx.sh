#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : skl2onnx
# Version       : 1.18.0
# Source repo   : https://github.com/onnx/sklearn-onnx
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
#   - skl2onnx (sklearn-onnx) is a pure Python library (PyPI: skl2onnx) that
#     converts scikit-learn models to ONNX format for interoperability with
#     ONNX-compatible runtimes.
#   - Pure Python wheel (py2.py3-none-any) — NOARCH=true, installed from PyPI.
#   - Runtime deps: onnx>=1.2.1, scikit-learn>=1.1, onnxconverter-common>=1.7.0.
#   - Upstream git tags use a 'v' prefix and omit the patch segment when it
#     is zero (e.g., 1.18.0 → tag v1.18; 1.18.1 → tag v1.18.1).
#   - Tests: pytest tests/ -x -q. Test suite exercises converter correctness
#     for all supported sklearn estimators. onnxruntime is recommended for
#     the full backend-validation tests.
#   - Tracking issue: LOZPY-TBD
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="skl2onnx"
PACKAGE_URL="https://github.com/onnx/sklearn-onnx"
NOARCH="true"

# Upstream git tags use a 'v' prefix and drop a trailing '.0' patch segment
# (e.g., 1.18.0 → v1.18;  1.18.1 → v1.18.1).
PACKAGE_VERSION="${1:-1.18.0}"
# Strip leading 'v' so we work with a bare number (e.g., 1.18.0)
PACKAGE_VERSION="${PACKAGE_VERSION#v}"
# Pin PYPI_VERSION now, before pre_clone mutates PACKAGE_VERSION to the git
# tag form (v1.18). The template derives PYPI_VERSION from PACKAGE_VERSION at
# install time, so without this it would attempt 'pip install skl2onnx==1.18'
# which does not exist on PyPI.
PYPI_VERSION="${PACKAGE_VERSION}"

# =============================================================================
# CALLBACK: pre_clone
# Convert the bare version to the upstream tag format before git checkout:
#   1.18.0  → v1.18   (trailing .0 dropped)
#   1.18.1  → v1.18.1 (non-zero patch kept)
# =============================================================================
pre_clone() {
    local tag="v${PACKAGE_VERSION}"
    # Drop trailing .0 patch segment to match upstream tag style
    if [[ "${tag}" =~ \.0$ ]]; then
        tag="${tag%.0}"
    fi
    PACKAGE_VERSION="${tag}"
}

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# Installs runtime and test dependencies then runs the skl2onnx test suite.
# onnxruntime enables backend validation tests (converts + runs inference).
# numpy and scikit-learn are required runtime deps.
# Expected: majority of tests pass on Python 3.10+ with onnxruntime installed.
# =============================================================================
custom_test_command() {
    log_info "Installing skl2onnx test dependencies..."
    pip install pytest \
        "onnx>=1.2.1" "onnxconverter-common>=1.7.0" \
        "scikit-learn>=1.1" "numpy>=1.18" \
        onnxruntime
    log_info "Running skl2onnx test suite..."
    pytest tests/ -x -q
    log_info "skl2onnx test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
