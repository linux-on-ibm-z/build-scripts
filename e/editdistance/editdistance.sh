#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : editdistance
# Version       : v0.6.2
# Source repo   : https://github.com/roy-ht/editdistance
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
#   - editdistance provides a fast C/Cython implementation of Levenshtein
#     (edit) distance.
#   - No s390x wheel on PyPI; must build from source.
#   - The template always runs its own `python -m build` (sdist -> wheel);
#     custom_build_command() is not called by this template version.
#   - The sdist excludes bycython.pyx (only .cpp/.pxd are manifested), so
#     setup.py fails with "doesn't match any files" when run from the extracted
#     sdist temp dir. post_clone() adds bycython.pyx to MANIFEST.in so it is
#     included in the sdist and available when setup.py runs.
#   - Cython must be installed before the build, handled in pre_build().
#   - The source editdistance/ directory is renamed before testing so Python
#     imports the installed compiled .so from the wheel, not the bare source.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="editdistance"
PACKAGE_VERSION="${1:-v0.6.2}"
PACKAGE_URL="https://github.com/roy-ht/editdistance"

NOARCH="false"

RH_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv gcc g++"
SLES_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++"

post_clone() {
    # The sdist does not include bycython.pyx (only the pre-generated .cpp).
    # setup.py calls cythonize("editdistance/bycython.pyx") which fails when
    # run from the extracted sdist temp dir where the .pyx is absent.
    # Add it to MANIFEST.in so the sdist bundles the .pyx file.
    echo "include editdistance/bycython.pyx" >> /workspace/editdistance/MANIFEST.in
}

pre_build() {
    pip install "cython>=0.29" setuptools wheel
}

custom_test_command() {
    pip install pytest

    # Rename the source package directory so Python imports the installed
    # compiled .so from the wheel rather than the bare source tree.
    if [ -d /workspace/editdistance/editdistance ]; then
        mv /workspace/editdistance/editdistance /workspace/editdistance/editdistance_src
    fi

    pytest /workspace/editdistance/test/ -v
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"
