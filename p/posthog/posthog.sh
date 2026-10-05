#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : posthog
# Version       : 2.4.0
# Source repo   : https://github.com/posthog/posthog-python
# Tested on     : UBI:9.6
# Language      : Python
# Ci-Check      : True
# Script License: Apache License, Version 2 or later
# Maintainer    : Build Scripts Team <build-scripts@ibm.com>
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="posthog"
PACKAGE_URL="https://github.com/posthog/posthog-python"
NOARCH="true"

# Upstream git tags are prefixed with 'v' (e.g., v2.4.0)
PACKAGE_VERSION="${1:-v2.4.0}"
if [[ "${PACKAGE_VERSION}" != v* ]]; then
    PACKAGE_VERSION="v${PACKAGE_VERSION}"
fi

# Upstream repo name is "posthog-python"
CLONE_DIR="posthog-python"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# =============================================================================
# CALLBACK: pre_build
# =============================================================================
pre_build() {
    if [[ -f ".gitmodules" ]]; then
        git submodule update --init --recursive
    fi

    pip install "setuptools>=60,<80" wheel build

    # Python 3.14+ compatibility: defaultdict.__missing__ no longer calls __setitem__
    python3 -c '
file = "posthog/utils.py"
with open(file, "r") as f:
    content = f.read()

target = "        super().__setitem__(key, value)"
fix = """        super().__setitem__(key, value)

    def __missing__(self, key):
        if len(self) >= self.max_size:
            self.clear()
        return super().__missing__(key)"""

if target in content and "__missing__" not in content:
    with open(file, "w") as f:
        f.write(content.replace(target, fix, 1))
'
}

# =============================================================================
# CALLBACK: custom_test_command
# =============================================================================
custom_test_command() {
    pip install . pytest freezegun mock

    if ! pytest posthog/test/ -v -W default::DeprecationWarning; then
        echo "------------------${PACKAGE_NAME}:Test_fails-------------------------------------"
        return 1
    fi
}

# =============================================================================
# Execute the build (invokes the Python template)
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"