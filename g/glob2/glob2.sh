#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : glob2
# Version       : 0.7
# Source repo   : https://github.com/miracle2k/python-glob2
# Tested on     : UBI:9.6
# Language      : Python
# Ci-Check      : True
# Script License: Apache License, Version 2 or later
# Maintainer    : Build Scripts Team <build-scripts@ibm.com>
#
# Disclaimer    : This script has been tested in root mode on given
# ==========      platform using the mentioned version of the package.
#                 It may not work as expected with newer versions of the
#                 package and/or distribution. In such case, please
#                 contact "Maintainer" of this script.
#
# Notes:
#   - glob2 is a pure Python library (PyPI: glob2) extending Python's built-in
#     glob module with support for '**' recursive wildcards and captured patterns.
#   - Pure Python wheel (py2.py3-none-any) — NOARCH=true, installed from PyPI.
#   - Upstream git tags use a 'v' prefix for release 0.7 (v0.7).
#   - Tests: 13 unit tests covering fnmatch, patterns, recursive globs, and hidden files.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="glob2"
PACKAGE_URL="https://github.com/miracle2k/python-glob2"
NOARCH="true"

# Upstream git tags use 'v' prefix (e.g., v0.7)
PACKAGE_VERSION="${1:-0.7}"
if [[ "${PACKAGE_VERSION}" != v* ]]; then
    PACKAGE_VERSION="v${PACKAGE_VERSION}"
fi

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git python3 python3-devel python3-pip"
DEB_DEP_PKGS="git python3 python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3 python3-devel python3-pip"

# =============================================================================
# CALLBACK: custom_test_command
# Upstream test.py uses custom setup/teardown methods written for nose / custom
# test runners. We execute the test cases via an adapter script to ensure setup
# and teardown are called properly across all supported Python versions.
# Expected: 13 passed tests.
# =============================================================================
custom_test_command() {
    log_info "Running glob2 test suite..."
    python3 - << 'EOF'
import unittest
import test

class TestFnmatchAdapter(unittest.TestCase):
    def test_filter_everything(self):
        test.TestFnmatch().test_filter_everything()
    def test_filter_single_character(self):
        test.TestFnmatch().test_filter_single_character()
    def test_sequence(self):
        test.TestFnmatch().test_sequence()

def make_test_case(cls):
    class TestCaseWrapper(unittest.TestCase):
        def setUp(self):
            self.impl = cls()
            self.impl.setup()
        def tearDown(self):
            self.impl.teardown()
    for name in dir(cls):
        if name.startswith('test'):
            fn = getattr(cls, name)
            def test_method(self, f=fn):
                f(self.impl)
            setattr(TestCaseWrapper, name, test_method)
    TestCaseWrapper.__name__ = cls.__name__
    return TestCaseWrapper

TestPatterns = make_test_case(test.TestPatterns)
TestRecursive = make_test_case(test.TestRecursive)
TestIncludeHidden = make_test_case(test.TestIncludeHidden)

suite = unittest.TestSuite()
for tc in [TestFnmatchAdapter, TestPatterns, TestRecursive, TestIncludeHidden]:
    suite.addTests(unittest.defaultTestLoader.loadTestsFromTestCase(tc))

runner = unittest.TextTestRunner(verbosity=2)
result = runner.run(suite)
if not result.wasSuccessful():
    raise SystemExit(1)
EOF
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
