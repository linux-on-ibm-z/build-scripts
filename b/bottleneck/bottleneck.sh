#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : bottleneck
# Version       : v1.6.0
# Source repo   : https://github.com/pydata/bottleneck
# Tested on     : UBI:9.3
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Pranjal-Patidar1 <pranjal.patidar1@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
#                 platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - Bottleneck is a C extension that requires numpy headers at build time.
#   - Built with --no-isolation so numpy installed in the venv is visible.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="bottleneck"
PACKAGE_VERSION="${1:-v1.6.0}"
PACKAGE_URL="https://github.com/pydata/bottleneck"

# NOARCH=true skips the template's build step which invokes setup.py before
# versioneer and numpy are installed, causing ModuleNotFoundError.
NOARCH="true"

RH_DEP_PKGS="git python3-devel python3-pip gcc"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv gcc"
SLES_DEP_PKGS="git python3-devel python3-pip gcc"

custom_test_command() {
    # Run pytest against the installed package using --pyargs so pytest never
    # touches the source tree's conftest.py (which tries to import the unbuilt
    # C extension and causes ModuleNotFoundError on s390x).
    cd /tmp
    pytest --pyargs bottleneck
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"