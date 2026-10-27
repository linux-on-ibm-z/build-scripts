#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : uc.micro-py
# Version       : 1.0.1
# Source repo   : https://github.com/tsutsu3/uc.micro-py
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Niyam Siwach <niyam@ibm.com>
#
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="uc.micro-py"
PACKAGE_VERSION="${1:-v1.0.1}"
PACKAGE_URL="https://github.com/tsutsu3/uc.micro-py"
PYPI_NAME="uc-micro-py"
PYPI_VERSION="${PACKAGE_VERSION#v}"
PACKAGE_VERSION="v${PYPI_VERSION}"

NOARCH="true"
RH_DEP_PKGS=""
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

source "${SCRIPT_DIR}/../../v2-templates/python.sh"
