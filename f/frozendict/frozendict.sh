#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : frozendict
# Version       : v2.4.2
# Source repo   : https://github.com/Marco-Sulla/python-frozendict
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
# Notes:
#   - frozendict is a pure-Python immutable mapping with an optional C extension
#   - C sources ship only for CPython 3.6-3.10; newer versions use pure Python
#   - Container environment provides: gcc/g++, python, pip
#   - Repository is pre-cloned with full history for version flexibility
# -----------------------------------------------------------------------------

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="frozendict"
PACKAGE_VERSION="${1:-v2.4.2}"
PACKAGE_URL="https://github.com/Marco-Sulla/python-frozendict"

# =============================================================================
# REQUIRED: Dependencies
# No extra system packages needed; build is pure Python
# =============================================================================
RH_DEP_PKGS=""

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
