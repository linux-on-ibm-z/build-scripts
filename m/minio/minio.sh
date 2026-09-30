#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : minio
# Version       : 7.2.15
# Source repo   : https://github.com/minio/minio-py
# Tested on     : UBI:9.6
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Viddya K <viddya.k@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
# ==========      platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="minio"
PACKAGE_VERSION="${1:-7.2.15}"
PACKAGE_URL="https://github.com/minio/minio-py"
NOARCH="true"

# The GitHub repo is named minio-py; the template clones into a dir
# derived from the URL basename, so we set CLONE_DIR explicitly.
CLONE_DIR="minio-py"

# =============================================================================
# REQUIRED: Dependencies
# minio is pure Python — only needs git + pip tooling
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../templates/python.sh"
