#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : tensorflow-metadata
# Version       : 1.16.1
# Source repo   : https://github.com/tensorflow/metadata
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
#   - tensorflow-metadata is a pure Python library (PyPI: tensorflow-metadata)
#     providing standard representations for metadata associated with TensorFlow
#     data pipelines (feature statistics, schemas, anomalies).
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - Runtime deps (Python>=3.11): absl-py<3.0.0, googleapis-common-protos<2,
#     protobuf<6.0.0dev,>=4.25.2.
#   - Upstream git tags use a 'v' prefix (e.g., v1.16.1); the bare version
#     (e.g., 1.16.1) is used for the PyPI install.
#   - Tests: pytest tensorflow_metadata/ -x -q.
#   - Tracking issue: LOZPY-TBD
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="tensorflow-metadata"
PACKAGE_URL="https://github.com/tensorflow/metadata"
NOARCH="true"

# Upstream git tags use a 'v' prefix (e.g., v1.16.1).
PACKAGE_VERSION="${1:-1.16.1}"
# Strip leading 'v' so we work with a bare number (e.g., 1.16.1)
PACKAGE_VERSION="${PACKAGE_VERSION#v}"
# Pin PYPI_VERSION now, before pre_clone adds the 'v' prefix for git checkout.
PYPI_VERSION="${PACKAGE_VERSION}"

# =============================================================================
# CALLBACK: pre_clone
# Add the 'v' prefix required by the upstream git tag (e.g., 1.16.1 → v1.16.1).
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
# Installs runtime and test dependencies then runs the tensorflow-metadata
# test suite.
# Expected: all tests pass on Python 3.10+.
# =============================================================================
custom_test_command() {
    log_info "Installing tensorflow-metadata test dependencies..."
    pip install pytest "absl-py<3.0.0,>=0.9" \
        "googleapis-common-protos<2,>=1.56.4" \
        "protobuf<6.0.0,>=4.25.2"
    log_info "Running tensorflow-metadata test suite..."
    pytest tensorflow_metadata/ -x -q
    log_info "tensorflow-metadata test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
