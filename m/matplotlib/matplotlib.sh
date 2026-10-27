#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : matplotlib
# Version       : v3.10.3
# Source repo   : https://github.com/matplotlib/matplotlib
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

# Get script directory for template sourcing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# PACKAGE_VERSION defaults to v3.10.3, overridable as $1
# =============================================================================
PACKAGE_NAME="matplotlib"
PACKAGE_VERSION="${1:-v3.10.3}"
PACKAGE_VERSION="v${PACKAGE_VERSION#v}"
PACKAGE_URL="https://github.com/matplotlib/matplotlib"

# =============================================================================
# REQUIRED: Dependencies
# System packages needed for building matplotlib
# =============================================================================
RH_DEP_PKGS="gcc gcc-c++ git pkgconf-pkg-config python3-devel python3-pip ninja-build"
DEB_DEP_PKGS="gcc g++ ninja-build pkg-config git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="gcc gcc-c++ ninja pkg-config git python3-devel python3-pip"

# =============================================================================
# OPTIONAL: Build configuration
# =============================================================================
PYPI_VERSION="${PACKAGE_VERSION#v}"

# =============================================================================
# CALLBACK: pre_build
# Runs inside the build environment, before the build starts
# =============================================================================
pre_build() {
    python -m pip install "meson-python>=0.13.1,<0.17.0" \
        "pybind11>=2.13.2,!=2.13.3,<3.1" "setuptools_scm>=7" ninja numpy pillow
}

# =============================================================================
# CALLBACK: custom_install
# Replaces the template's default install step
# =============================================================================
custom_install() {
    # Limit parallel compilation jobs to prevent OOM on 8GB memory limit
    # Matplotlib's C++ compilation is memory-intensive
    export MESON_BUILD_JOBS=2
    python -m build --wheel --no-isolation
}

# =============================================================================
# CALLBACK: pre_test
# Installs test prerequisites before the test phase
# =============================================================================
pre_test() {
    # Newer pyparsing warns on APIs used by 3.10.3; upstream treats warnings
    # as errors. Keep the test dependency on the release-era API.
    python -m pip install "pyparsing>=2.3.1,<3.3" "pytest>=7,<9"
}

# =============================================================================
# CALLBACK: custom_test_command
# Replaces the template's default test command
# =============================================================================
custom_test_command() {
    # Run core upstream tests against installed native extensions, using source
    # test data because release wheels omit the test suite. GUI/TeX tests are
    # outside this headless validation subset.
    # Place tests beside the installed code: Python >=3.12 warning stacklevel
    # checks rely on tests and implementation sharing the same package prefix.
    local checkout="$PWD"
    (cd /tmp && python - "$checkout" <<'PYTEST'
import os
from pathlib import Path
import shutil
import sys
import matplotlib
import pytest
assert "site-packages" in matplotlib.__file__, matplotlib.__file__
os.chdir(sys.argv[1])
installed_package = Path(matplotlib.__file__).resolve().parent
shutil.copytree(Path("lib/matplotlib/tests"), installed_package / "tests",
                dirs_exist_ok=True)
modules = ["api", "cbook", "colors", "path", "transforms", "triangulation"]
sys.exit(pytest.main([
    "--import-mode=importlib", "-c", str(Path("pyproject.toml").resolve()),
    "-o", "addopts=", "-q",
    *[str(installed_package / "tests" / f"test_{name}.py") for name in modules],
]))
PYTEST
    )
}

# Use the bundled FreeType and Qhull versions expected by upstream image tests.
# Meson downloads these sources during the build; a C++17 compiler is required.
export MPLBACKEND=Agg

# =============================================================================
# Source the python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
