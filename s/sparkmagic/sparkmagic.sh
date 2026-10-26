#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : sparkmagic
# Version       : 0.22.0
# Source repo   : https://github.com/jupyter-incubator/sparkmagic
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
#   - Monorepo: the buildable sparkmagic package lives under sparkmagic/;
#     the checkout root holds a poetry workspace pyproject.toml, not a wheel
#   - hdijupyterutils and autovizwidget are sibling sub-packages; install them
#     from PyPI before building so --no-isolation can resolve requirements.txt
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REQUIRED: Package metadata
PACKAGE_NAME="sparkmagic"
PACKAGE_VERSION="${1:-0.22.0}"
PACKAGE_URL="https://github.com/jupyter-incubator/sparkmagic"

# REQUIRED: Dependencies
RH_DEP_PKGS="krb5-devel"
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# numpy version gate; evaluated at script start where python3 is available
NUMPY_VER="1.23.5"
if python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 12) else 1)' 2>/dev/null; then
    NUMPY_VER="1.26.2"
fi

# CALLBACK: custom_install: own the full build because the checkout root is a
# poetry workspace, not an installable package; the wheel must land in OUTPUT_DIR
custom_install() {
    # Install sibling packages so sparkmagic/requirements.txt resolves with --no-isolation
    pip install hdijupyterutils==0.22.0 autovizwidget==0.22.0

    # Copy top-level licence into the sub-package directory before building
    cp LICENSE.md sparkmagic/

    cd sparkmagic/
    python -m build --no-isolation
    mkdir -p "${OUTPUT_DIR}"
    cp dist/*.whl "${OUTPUT_DIR}/"
}

# CALLBACK: pre_test: install test prerequisites inside .venv-test
pre_test() {
    pip install "numpy==${NUMPY_VER}" mock
}

# Source the python template to execute the build workflow
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
