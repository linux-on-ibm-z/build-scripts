#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : prometheus-client
# Version       : v0.21.1
# Source repo   : https://github.com/prometheus/client_python
# Tested on     : UBI:9.6
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
#   - NOARCH=true: wheel is installed directly from PyPI, no local build needed
#   - PYPI_VERSION strips the leading "v" that PyPI does not use
#   - Pure-Python library from prometheus, no compiled extension
#   - Published noarch wheel installed via NOARCH, not rebuilt
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="prometheus-client"
PACKAGE_VERSION="${1:-v0.21.1}"
PACKAGE_URL="https://github.com/prometheus/client_python"

# OPTIONAL: Build configuration
# Upstream publishes noarch wheels; install from PyPI rather than rebuilding.
NOARCH="true"

# REQUIRED: Dependencies
RH_DEP_PKGS=""

# OPTIONAL: Build configuration
# PyPI does not use the leading "v" that the Git tag carries.
PYPI_VERSION="${PACKAGE_VERSION#v}"

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
