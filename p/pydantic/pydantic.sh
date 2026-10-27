#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : pydantic
# Version       : 2.11.4
# Source repo   : https://github.com/pydantic/pydantic
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
#   - pydantic is a Python data validation library using type annotations.
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - Runtime deps: pydantic-core (with same version), annotated-types,
#     typing-extensions>=4.12.2.
#   - Upstream git tags use a 'v' prefix (e.g., v2.11.4).
#   - Tests: pytest tests/ -x -q
#     Expected: majority of tests pass on Python 3.10+.
#   - Tracking issue: LOZPY-TBD
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="pydantic"
PACKAGE_URL="https://github.com/pydantic/pydantic"
NOARCH="true"

# Upstream git tags use a 'v' prefix (e.g., v2.11.4).
# Pin PYPI_VERSION to the bare number before adding the 'v' back for cloning,
# so the template installs 'pydantic==2.11.4' rather than 'pydantic==v2.11.4'.
PACKAGE_VERSION="${1:-2.11.4}"
PACKAGE_VERSION="${PACKAGE_VERSION#v}"   # normalise to bare number
PYPI_VERSION="${PACKAGE_VERSION}"        # remember bare version for PyPI install
PACKAGE_VERSION="v${PACKAGE_VERSION}"   # restore 'v' prefix for git tag checkout

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: pre_test
# pydantic==2.11.4 hard-pins pydantic-core==2.33.2, which has no pre-built
# Python 3.14 wheel and cannot be compiled from source (jiter-0.9.0 calls
# PyUnicode_New/KIND/DATA/1BYTE_KIND — all removed in CPython 3.14).
# The first pydantic-core with a real cp314 wheel is 2.46.0, shipped by
# pydantic==2.13.0. On Python 3.14 we therefore override PYPI_VERSION so the
# template installs pydantic==2.13.0 instead of 2.11.4.
# On Python 3.10–3.13 the requested version 2.11.4 is used unchanged.
# =============================================================================
pre_test() {
    local py_minor
    py_minor="$(python -c 'import sys; print(sys.version_info.minor)')"
    if [[ "${py_minor}" -ge 14 ]]; then
        log_info "Python 3.${py_minor} detected: pydantic-core==2.33.2 (bundled with pydantic 2.11.4) has no cp314 wheel and cannot be built from source (removed CPython Unicode internals)."
        log_info "Upgrading to pydantic==2.13.0 which pins pydantic-core==2.46.0 (first version with a cp314 manylinux wheel)."
        PYPI_VERSION="2.13.0"
    fi
}

# =============================================================================
# CALLBACK: custom_test_command
# Installs test dependencies and runs the pydantic test suite.
# Expected: majority of tests pass on Python 3.10+.
# =============================================================================
custom_test_command() {
    log_info "Installing pydantic test dependencies..."
    pip install pytest pytest-mock \
        "annotated-types>=0.4.0" \
        "typing-extensions>=4.12.2" \
        dirty-equals email-validator \
        fastapi
    log_info "Running pydantic test suite..."
    pytest tests/ -x -q \
        --ignore=tests/benchmarks
    log_info "pydantic test suite completed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
