#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : osqp
# Version       : v0.6.3
# Source repo   : https://github.com/osqp/osqp-python
# Tested on     : UBI:9.8
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Sai-Sindhuri-Avulamanda <Sai.Sindhuri.Avulamanda@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
# ==========      platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
#     the C library (osqp_sources submodule) before compiling the CPython extension
#     installed in pre_build() because the template builds with --no-isolation
#
# Notes:
#   - Python wrapper for the OSQP QP solver; setup.py drives a CMake build of
#   - cmake is required at build time to compile the static osqp library
#   - build-system.requires (oldest-supported-numpy, setuptools_scm, qdldl) are
#   - C library with Python bindings
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="osqp"
PACKAGE_VERSION="${1:-v0.6.3}"
PACKAGE_URL="https://github.com/osqp/osqp-python"

# REQUIRED: Dependencies
RH_DEP_PKGS="cmake"
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# CALLBACK: pre_build: in the build env, before the build
pre_build() {
    pip install "scipy" "oldest-supported-numpy" "setuptools>=40.8.0" "setuptools_scm>=6.2" "qdldl"
}

# CALLBACK: custom_test_command: replaces the default test command
custom_test_command() {
    # codegen tests invoke osqp.OSQP.codegen() which compiles C at test time;
    # upstream excludes them in pyproject.toml test-command (line 12).
    # Excluded: codegen_matrices_test.py -- requires C compiler + cmake at test time;
    #   platform-independent: upstream excludes on all platforms in pyproject.toml.
    # Excluded: codegen_vectors_test.py -- same reason as above.
    # Excluded: mkl_pardiso_test.py::mkl_pardiso_tests::test_issue14 -- requires
    #   Intel MKL Pardiso which is unavailable on s390x and on stock x86_64 RHEL9;
    #   upstream excludes on all platforms in pyproject.toml (not s390x-specific).
    pytest \
        --deselect src/osqp/tests/codegen_matrices_test.py::codegen_matrices_tests::test_solve \
        --deselect src/osqp/tests/codegen_matrices_test.py::codegen_matrices_tests::test_update_P \
        --deselect src/osqp/tests/codegen_matrices_test.py::codegen_matrices_tests::test_update_P_allind \
        --deselect src/osqp/tests/codegen_matrices_test.py::codegen_matrices_tests::test_update_A \
        --deselect src/osqp/tests/codegen_matrices_test.py::codegen_matrices_tests::test_update_A_allind \
        --deselect src/osqp/tests/codegen_matrices_test.py::codegen_matrices_tests::test_update_P_A_indP_indA \
        --deselect src/osqp/tests/codegen_matrices_test.py::codegen_matrices_tests::test_update_P_A_indP \
        --deselect src/osqp/tests/codegen_matrices_test.py::codegen_matrices_tests::test_update_P_A_indA \
        --deselect src/osqp/tests/codegen_matrices_test.py::codegen_matrices_tests::test_update_P_A_allind \
        --deselect src/osqp/tests/codegen_vectors_test.py::codegen_vectors_tests::test_solve \
        --deselect src/osqp/tests/codegen_vectors_test.py::codegen_vectors_tests::test_update_q \
        --deselect src/osqp/tests/codegen_vectors_test.py::codegen_vectors_tests::test_update_l \
        --deselect src/osqp/tests/codegen_vectors_test.py::codegen_vectors_tests::test_update_u \
        --deselect src/osqp/tests/codegen_vectors_test.py::codegen_vectors_tests::test_update_bounds \
        --deselect src/osqp/tests/mkl_pardiso_test.py::mkl_pardiso_tests::test_issue14
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
