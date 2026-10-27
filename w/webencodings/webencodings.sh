#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : webencodings
# Version       : 0.5.1
# Source repo   : https://github.com/gsnedders/python-webencodings
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Niyam Siwach <niyam@ibm.com>
#
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="webencodings"
PACKAGE_VERSION="${1:-v0.5.1}"
PACKAGE_URL="https://github.com/gsnedders/python-webencodings"
PYPI_NAME="webencodings"
PYPI_VERSION="${PACKAGE_VERSION#v}"
PACKAGE_VERSION="v${PYPI_VERSION}"

NOARCH="true"
RH_DEP_PKGS=""
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

source "${SCRIPT_DIR}/../../v2-templates/python.sh"
