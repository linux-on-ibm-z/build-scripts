#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : distro
# Version       : v1.8.0
# Source repo   : https://github.com/nir0s/distro
# Tested on     : UBI:9.3
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Pranjal-Patidar1 <pranjal.patidar1@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on the given
#                 platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact the "Maintainer" of this script.
#
# Notes:
#   - distro is a pure Python library for detecting Linux distributions.
#   - No native C/C++ compilation is required.
#   - The package is marked as NOARCH.
#   - NOARCH packages are installed from PyPI by the Python template.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="distro"
PACKAGE_VERSION="${1:-v1.8.0}"
PACKAGE_URL="https://github.com/nir0s/distro"

NOARCH="true"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3-devel python3-pip"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3-devel python3-pip"

# =============================================================================
# Execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"