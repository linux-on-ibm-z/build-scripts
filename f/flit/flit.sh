#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : flit
# Version       : 3.9.0
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
#   - flit is a simple packaging tool for putting Python packages on PyPI.
#     It provides a lightweight alternative to setuptools/twine for packages
#     that use pyproject.toml.
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - Runtime deps: flit_core>=3.9.0, requests, docutils, tomli-w.
#   - Upstream git tags have no 'v' prefix (e.g., 3.9.0).
#   - Tests span two sub-trees: flit_core/flit_core/tests/ and tests/.
#     206 passed, 3 warnings on Python 3.11; 206 passed, 190 warnings on 3.12.
#     Warnings on 3.12 are DeprecationWarnings for ast.Str/ast.Attribute.s and
#     datetime.utcfromtimestamp() — all upstream issues, no test failures.
#   - Test deps (pyproject.toml [test] extra): testpath, responses,
#     pytest>=2.7.3, pytest-cov, tomli.
#   - Tracking issue: LOZPY-399
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="flit"
PACKAGE_URL="https://github.com/pypa/flit"
NOARCH="true"

# Upstream git tags have no 'v' prefix (e.g., 3.9.0)
PACKAGE_VERSION="${1:-3.9.0}"
# Strip leading 'v' if caller passes v3.9.0 style
PACKAGE_VERSION="${PACKAGE_VERSION#v}"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: pre_test
# Installs test dependencies declared in pyproject.toml [project.optional-dependencies.test].
# These are not pulled in by the runtime PyPI install of flit.
# =============================================================================
pre_test() {
    log_info "Installing flit test dependencies..."
    pip install testpath responses "pytest>=2.7.3" pytest-cov tomli
}

# =============================================================================
# CALLBACK: custom_test_command
# flit's tests live in two sub-trees:
#   - flit_core/flit_core/tests/test_*.py  (flit_core unit tests)
#   - tests/test_*.py                      (flit integration tests)
# The template's default pytest glob (*/test_*.py, tests/test_*.py) only
# discovers the top-level tests/ tree and misses flit_core/flit_core/tests/.
# Running pytest from the repo root with explicit paths covers both trees.
# Expected: 206 passed on Python 3.11 and 3.12.
# =============================================================================
custom_test_command() {
    log_info "Running flit test suite..."
    pytest flit_core/flit_core/tests/ tests/ -v
    log_info "flit test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
