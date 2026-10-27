#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : transformers
# Version       : 4.49.0
# Source repo   : https://github.com/huggingface/transformers
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
#   - transformers is a pure Python library (PyPI: transformers) by Hugging
#     Face providing thousands of pretrained models for NLP, vision, audio,
#     and multimodal tasks, with backends for PyTorch, TensorFlow, and JAX.
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - Core runtime deps: filelock, huggingface-hub>=0.26.0, numpy>=1.17,
#     packaging>=20.0, pyyaml>=5.1, regex!=2019.12.17, requests,
#     tokenizers>=0.21,<0.22, safetensors>=0.4.1, tqdm>=4.27.
#   - Upstream git tags use a 'v' prefix (e.g., v4.49.0); the bare version
#     (e.g., 4.49.0) is used for the PyPI install.
#   - Tests: pytest tests/ -x -q --ignore=tests/pipelines.
#     The transformers test suite is large; heavy model-download tests are
#     gated by RUN_SLOW=true which is not set in CI. Fast unit tests (no
#     model weights needed) are run by default. Pipeline integration tests
#     are excluded to avoid network model downloads.
#   - Tracking issue: LOZPY-TBD
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="transformers"
PACKAGE_URL="https://github.com/huggingface/transformers"
NOARCH="true"

# Upstream git tags use a 'v' prefix (e.g., v4.49.0).
PACKAGE_VERSION="${1:-4.49.0}"
# Strip leading 'v' so we work with a bare number (e.g., 4.49.0)
PACKAGE_VERSION="${PACKAGE_VERSION#v}"
# Pin PYPI_VERSION now, before pre_clone adds the 'v' prefix for git checkout.
PYPI_VERSION="${PACKAGE_VERSION}"

# =============================================================================
# CALLBACK: pre_clone
# Add the 'v' prefix required by the upstream git tag (e.g., 4.49.0 → v4.49.0).
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
# Installs core runtime and test dependencies then runs the transformers fast
# (non-slow) test suite. torch (CPU-only) is the primary backend; pytest-xdist
# allows parallel execution for the large suite. RUN_SLOW is intentionally not
# set so model-download tests are skipped. Pipeline and trainer tests are
# excluded as they perform full model inference.
# Expected: core tokenizer, configuration, and utility tests pass on Python 3.10+.
# =============================================================================
custom_test_command() {
    log_info "Installing transformers test dependencies..."
    pip install pytest pytest-xdist pytest-timeout \
        "filelock" "huggingface-hub>=0.26.0" "numpy>=1.17" \
        "packaging>=20.0" "pyyaml>=5.1" "regex!=2019.12.17" \
        "requests" "tokenizers>=0.21,<0.22" "safetensors>=0.4.1" \
        "tqdm>=4.27" "torch" "accelerate"
    log_info "Running transformers test suite (fast tests only)..."
    RUN_SLOW=false \
        pytest tests/ \
            --ignore=tests/pipelines \
            --ignore=tests/trainer \
            -x -q
    log_info "transformers test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
