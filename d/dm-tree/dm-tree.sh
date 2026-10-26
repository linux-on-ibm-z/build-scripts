#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : dm-tree
# Version       : 0.1.9
# Source repo   : https://github.com/google-deepmind/tree
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
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="dm-tree"
PACKAGE_VERSION="${1:-0.1.9}"
PACKAGE_URL="https://github.com/google-deepmind/tree"
CLONE_DIR="tree"

NOARCH="true"

RH_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++ cmake"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv build-essential cmake"
SLES_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++ cmake"

custom_test_command() {
    pip install absl-py
    # Use --pyargs so pytest resolves 'tree.tree_test' via the installed package
    # (which has the compiled _tree C extension) instead of the local source tree.
    cd /tmp
    pytest --pyargs tree.tree_test
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"