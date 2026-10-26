#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : xmltodict
# Version       : 0.14.2
# Source repo   : https://github.com/martinblech/xmltodict
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Niyam Siwach <niyam@ibm.com>
#
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="xmltodict"
PACKAGE_VERSION="${1:-v0.14.2}"
PACKAGE_URL="https://github.com/martinblech/xmltodict"
PYPI_NAME="xmltodict"
PYPI_VERSION="${PACKAGE_VERSION#v}"
PACKAGE_VERSION="v${PYPI_VERSION}"

NOARCH="true"
RH_DEP_PKGS=""
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

source "${SCRIPT_DIR}/../../v2-templates/python.sh"
