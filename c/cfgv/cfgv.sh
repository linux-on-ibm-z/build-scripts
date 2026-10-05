#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : cfgv
# Version       : v3.4.0
# Source repo   : https://github.com/asottile/cfgv
# Tested on     : UBI:9.7
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Viddya K <viddya.k@ibm.com>
#
# Notes:
#   - cfgv is a pure Python library for validating configuration files
#   - No C extensions; package is installed directly from PyPI (NOARCH mode)
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="cfgv"
PACKAGE_VERSION="${1:-v3.4.0}"
PACKAGE_URL="https://github.com/asottile/cfgv"
NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# cfgv is pure Python — only needs git + pip tooling
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# =============================================================================
# Execute the build (invokes the Python template)
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
