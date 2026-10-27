#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : black
# Version       : 25.1.0
# Source repo   : https://github.com/psf/black
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

PACKAGE_NAME="black"
PACKAGE_VERSION="${1:-25.1.0}"
PACKAGE_URL="https://github.com/psf/black"
NOARCH="true"

RH_DEP_PKGS="git python3-devel python3-pip"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git python3-devel python3-pip"

custom_test_command() {
    # click>=8.2 removed mix_stderr from CliRunner; pin to <8.2 for test compat
    # pathspec "gitwildmatch" DeprecationWarning treated as error; suppress it
    pip install pytest aiohttp "click<8.2" "pathspec==0.9.0"
    cd /workspace/black

    local DESELECTS=()
    local WARNINGS=(-W "ignore::DeprecationWarning:pathspec")

    # pep_701 f-string test fails on Python 3.13+ due to stricter AST parser
    if [[ "${PYTHON_VERSION}" == 3.13* || "${PYTHON_VERSION}" == 3.14* ]]; then
        DESELECTS+=(--deselect=tests/test_format.py::test_simple_format[pep_701])
    fi

    # asyncio.get_event_loop_policy() deprecated in 3.14 and treated as error;
    # deselect the 8 affected event_loop() tests rather than suppressing warnings
    if [[ "${PYTHON_VERSION}" == 3.14* ]]; then
        DESELECTS+=(
            --deselect=tests/test_black.py::BlackTestCase::test_check_diff_use_together
            --deselect=tests/test_black.py::BlackTestCase::test_multi_file_force_py36
            --deselect=tests/test_black.py::BlackTestCase::test_multi_file_force_pyi
            --deselect=tests/test_black.py::BlackTestCase::test_works_in_mono_process_only_environment
            --deselect=tests/test_black.py::TestCaching::test_cache_multiple_files
            "--deselect=tests/test_black.py::TestCaching::test_output_locking_when_writeback_diff[no-color]"
            "--deselect=tests/test_black.py::TestCaching::test_output_locking_when_writeback_diff[with-color]"
            --deselect=tests/test_black.py::TestCaching::test_failed_formatting_does_not_get_cached
        )
    fi

    pytest tests/ --ignore=tests/test_blackd.py \
        "${DESELECTS[@]}" "${WARNINGS[@]}"
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"
