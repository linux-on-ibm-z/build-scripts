#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : numpy
# Version       : v2.4.0
# Source repo   : https://github.com/numpy/numpy
# Tested on     : UBI:9.6
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Viddya K <viddya.k@ibm.com>
#
# Notes:
#   - numpy is the fundamental package for scientific computing in Python
#   - Requires C/C++ compiler, Meson build system, and Ninja
#   - Applies patch for s390x GCD overflow fix (upstream PR #31360)
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="numpy"
PACKAGE_VERSION="${1:-v2.4.0}"
PACKAGE_URL="https://github.com/numpy/numpy"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git gcc gcc-c++ make cmake python3-devel python3-pip"
DEB_DEP_PKGS="git gcc g++ make cmake python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git gcc gcc-c++ make cmake python3-devel python3-pip"

# =============================================================================
# CALLBACK: post_clone
# Apply s390x GCD overflow fix patch after checkout
# =============================================================================
post_clone() {
    log_info "Applying patch for s390x GCD overflow fix..."
    git apply --ignore-whitespace "${SCRIPT_DIR}/patches/numpy_v2.4.0.patch"
}

# =============================================================================
# CALLBACK: pre_build
# Install build backend and build dependencies (meson, meson-python, ninja)
# Note: Runs INSIDE .venv-build
# =============================================================================
pre_build() {
    log_info "Installing build dependencies (meson, meson-python, ninja, cython)..."
    pip install wheel meson meson-python ninja "cython>=3.0.6"
}

# =============================================================================
# CALLBACK: custom_test_command
# Run numpy tests
# =============================================================================
custom_test_command() {
    log_info "Installing test dependencies..."
    # meson is required so f2py's util.py can run check_compilers() at import
    # time; without it ALL f2py test files fail at collection with FileNotFoundError
    pip install hypothesis pytest meson

    log_info "Running numpy tests (label=fast — skips slow/network/memory-heavy tests)..."
    cd /tmp
    # numpy.test() defaults to label='fast', equivalent to -m "not slow and not network"
    # This matches the IBM Z reference script and prevents OOM from large array tests.
    # test_mem_policy.py is excluded: it spawns subprocesses to set OS-level NUMA memory
    # policies which are not permitted in containerized environments (subprocess.CalledProcessError)
    python -c "import numpy, sys; sys.exit(numpy.test(label='fast', verbose=2, \
        extra_argv=['--deselect=_core/tests/test_mem_policy.py']) is False)"
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
