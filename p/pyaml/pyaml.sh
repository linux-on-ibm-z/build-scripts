#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : pyaml
# Version       : 25.7.0
# Source repo   : https://github.com/mk-fg/pretty-yaml
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
#   - pyaml is a PyYAML-based module to produce prettier, more human-readable
#     YAML-serialized data. Source repo is "pretty-yaml" (GitHub: mk-fg).
#   - Pure Python wheel (py3-none-any) — NOARCH=true, installed from PyPI.
#   - Upstream git tags have no 'v' prefix (e.g., 25.7.0).
#   - Tests: pytest pyaml/tests/ → 40 passed on Python 3.11 and 3.12.
#     Tests live at pyaml/tests/test_*.py — matched by the template default glob.
#     No extra test dependencies beyond pytest (installed by template).
#   - Tracking issue: LOZPY-363
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="pyaml"
PACKAGE_URL="https://github.com/mk-fg/pretty-yaml"
NOARCH="true"

# Upstream git tags have no 'v' prefix (e.g., 25.7.0)
PACKAGE_VERSION="${1:-25.7.0}"
# Strip leading 'v' if caller passes v25.7.0 style
PACKAGE_VERSION="${PACKAGE_VERSION#v}"

# Upstream repo name is "pretty-yaml"
CLONE_DIR="pretty-yaml"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
