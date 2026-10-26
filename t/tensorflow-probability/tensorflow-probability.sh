#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : tensorflow-probability
# Version       : 0.25.0
# Source repo   : https://github.com/tensorflow/probability
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
#   - tensorflow-probability is a pure Python library (PyPI: tensorflow-
#     probability) for probabilistic reasoning and statistical analysis
#     built on TensorFlow, including distributions, bijectors, and MCMC.
#   - Pure Python wheel (py2.py3-none-any) — NOARCH=true, installed from PyPI.
#   - Runtime deps: absl-py, six>=1.10.0, numpy>=1.13.3, decorator,
#     cloudpickle>=1.3, gast>=0.3.2.
#   - Upstream git tags use a 'v' prefix (e.g., v0.25.0); the bare version
#     (e.g., 0.25.0) is used for the PyPI install.
#   - Tests: pytest tensorflow_probability/ -x -q.
#     TensorFlow is required as the computation backend.
#   - Tracking issue: LOZPY-TBD
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="tensorflow-probability"
PACKAGE_URL="https://github.com/tensorflow/probability"
NOARCH="true"

# Upstream git tags use a 'v' prefix (e.g., v0.25.0).
PACKAGE_VERSION="${1:-0.25.0}"
# Strip leading 'v' so we work with a bare number (e.g., 0.25.0)
PACKAGE_VERSION="${PACKAGE_VERSION#v}"
# Pin PYPI_VERSION now, before pre_clone adds the 'v' prefix for git checkout.
PYPI_VERSION="${PACKAGE_VERSION}"

# =============================================================================
# CALLBACK: pre_clone
# Add the 'v' prefix required by the upstream git tag (e.g., 0.25.0 → v0.25.0).
# =============================================================================
pre_clone() {
    PACKAGE_VERSION="v${PACKAGE_VERSION}"
}

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# Installs runtime and test dependencies then runs the tensorflow-probability
# test suite. TensorFlow is required as the computation backend.
# Expected: majority of tests pass on Python 3.10+ with TensorFlow installed.
# =============================================================================
custom_test_command() {
    log_info "Installing tensorflow-probability test dependencies..."
    pip install pytest "absl-py" "six>=1.10.0" "numpy>=1.13.3" \
        "decorator" "cloudpickle>=1.3" "gast>=0.3.2" tensorflow
    log_info "Running tensorflow-probability test suite..."
    pytest tensorflow_probability/ -x -q \
        --ignore=tensorflow_probability/python/experimental
    log_info "tensorflow-probability test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
