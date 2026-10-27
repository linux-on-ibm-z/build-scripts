#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : tenacity
# Version       : 8.2.2
# Source repo   : https://github.com/jd/tenacity
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
#     Python in the matrix, so NOARCH pulls the wheel directly from PyPI
#
# Notes:
#   - Test suite requires tornado and typeguard; installed in pre_test()
#   - No system packages beyond the container toolchain are needed
#   - Pure-Python library from jd, no compiled extension
#   - Published noarch wheel installed via NOARCH, not rebuilt
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="tenacity"
PACKAGE_VERSION="${1:-8.2.2}"
PACKAGE_URL="https://github.com/jd/tenacity"

# OPTIONAL: Build configuration
# Upstream publishes noarch wheels for every supported Python at this version
NOARCH="true"

# REQUIRED: Dependencies
RH_DEP_PKGS=""
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# CALLBACK: pre_test: installs test prerequisites
pre_test() {
    pip install tornado typeguard
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
