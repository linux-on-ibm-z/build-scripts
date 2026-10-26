#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : tensorflow-hub
# Version       : 0.16.1
# Source repo   : https://github.com/tensorflow/hub
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
#   - tensorflow-hub is a pure Python library (PyPI: tensorflow-hub) for
#     reusable machine learning modules, enabling transfer learning with
#     TensorFlow SavedModel and TF1 Hub format assets.
#   - Pure Python wheel (py2.py3-none-any) — NOARCH=true, installed from PyPI.
#   - Runtime deps: numpy>=1.12.0, protobuf>=3.19.6, tf-keras>=2.14.1.
#   - Upstream git tags use a 'v' prefix (e.g., v0.16.1); the bare version
#     (e.g., 0.16.1) is used for the PyPI install.
#   - Tests: pytest tensorflow_hub/ -x -q (tests live alongside source).
#   - Tracking issue: LOZPY-TBD
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="tensorflow-hub"
PACKAGE_URL="https://github.com/tensorflow/hub"
NOARCH="true"

# Upstream git tags use a 'v' prefix (e.g., v0.16.1).
PACKAGE_VERSION="${1:-0.16.1}"
# Strip leading 'v' so we work with a bare number (e.g., 0.16.1)
PACKAGE_VERSION="${PACKAGE_VERSION#v}"
# Pin PYPI_VERSION now, before pre_clone adds the 'v' prefix for git checkout.
PYPI_VERSION="${PACKAGE_VERSION}"

# =============================================================================
# CALLBACK: pre_clone
# Add the 'v' prefix required by the upstream git tag (e.g., 0.16.1 → v0.16.1).
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
# Installs runtime and test dependencies then runs the tensorflow-hub test suite.
# tensorflow is the primary backend; tf-keras is a required runtime dep.
# Expected: majority of tests pass on Python 3.10+ with TensorFlow installed.
# =============================================================================
custom_test_command() {
    log_info "Installing tensorflow-hub test dependencies..."
    pip install pytest "numpy>=1.12.0" "protobuf>=3.19.6" \
        "tf-keras>=2.14.1" tensorflow
    log_info "Running tensorflow-hub test suite..."
    pytest tensorflow_hub/ -x -q \
        --ignore=tensorflow_hub/tools
    log_info "tensorflow-hub test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
