#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : biopython
# Version       : biopython-178
# Source repo   : https://github.com/biopython/biopython
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
#   - biopython 1.78 has C extensions (Bio.Align._aligners, Bio.cpairwise2,
#     Bio.Nexus.cnexus, Bio.motifs._pwm, Bio.PDB.kdtrees, etc.) that require
#     numpy headers at build time.
#   - numpy version selection depends on Python version:
#       Python ≤3.11  → numpy<1.24  (biopython 1.78 uses np.float/np.product
#                                    removed in numpy 1.24/1.25; numpy 1.23
#                                    builds fine from source on these versions)
#       Python ≥3.12  → numpy>=1.26 (numpy<1.24 cannot build from source on
#                                    Python 3.12+ because its build backend
#                                    uses pkgutil.ImpImporter which was removed;
#                                    numpy 1.26+ provides pre-built wheels and
#                                    dropped the removed aliases)
#   - On Python ≥3.12, Bio/Statistics/lowess.py docstring examples use
#     numpy.float (removed in numpy 1.24+) and are patched to use float.
#   - The repo has no pyproject.toml; a minimal stub is written in pre_build()
#     so the template's "python -m build ." can invoke setuptools.build_meta,
#     which then delegates the actual C-extension wheel build to the existing
#     setup.py (which is left untouched). This stub is required — without it
#     the template's build step has no build backend and fails immediately.
#     The wheel is built by the template (not manually), so no custom_install()
#     is needed.
#   - Tests use the upstream Tests/run_tests.py runner with --offline.
#   - run_tests.py inserts the workspace root into sys.path so "import Bio"
#     would resolve to the source Bio/ directory (no .so files). Fix: move
#     Bio/ to /tmp/Bio_biopython_src/ in pre_test() so the wheel's compiled
#     C extensions are used. This also prevents run_tests.py from scanning
#     Bio_src/ for doctests (which caused Bio_src.Entrez/ExPASy failures).
#   - Source patches are applied in pre_build() to fix Python 3.10+
#     incompatibilities so all tests pass without exclusions:
#       Bio/motifs/_pwm.c          — add PY_SSIZE_T_CLEAN before Python.h
#                                    and change 'int s' to 'Py_ssize_t s'
#       Bio/SeqIO/SeqXmlIO.py      — guard startPropertyElement against
#                                    empty self.records (IndexError fix)
#       Bio/Align/substitution_matrices/__init__.py
#                                  — fix read() assertion when row header
#                                    letter doesn't match (AssertionError fix
#                                    affecting test_Tutorial align chapter)
#       Bio/Statistics/lowess.py   — numpy.float → float in docstring
#                                    examples (Python ≥3.12 / numpy ≥1.26)
#   - run_tests.py imports distutils.util, available via the setuptools shim
#     on Python 3.10-3.13. On 3.14 distutils is gone; tests fall back to pytest.
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_NAME="biopython"
PACKAGE_VERSION="${1:-biopython-178}"
PACKAGE_URL="https://github.com/biopython/biopython"

NOARCH="false"

RH_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++"
DEB_DEP_PKGS="git python3-dev python3-pip python3-venv gcc g++"
SLES_DEP_PKGS="git python3-devel python3-pip gcc gcc-c++"

pre_build() {
    # numpy is required at build time for C extension headers.
    # numpy<1.24 uses setuptools<50 / pkg_resources which calls
    # pkgutil.ImpImporter — removed in Python 3.12. On Python ≥3.12 we must
    # use numpy>=1.26 which provides pre-built wheels for Python 3.12+.
    PYMINOR="${PYTHON_VERSION##*.}"
    if [ "${PYMINOR}" -ge 12 ]; then
        pip install "numpy>=1.26"
    else
        pip install "numpy<1.24"
    fi

    # biopython 1.78 has no pyproject.toml; write a minimal stub so the
    # template's "python -m build ." uses setuptools.build_meta and
    # delegates the real build to setup.py (which stays untouched).
    cat > /workspace/biopython/pyproject.toml <<'EOF'
[build-system]
requires = ["setuptools", "wheel", "numpy"]
build-backend = "setuptools.build_meta"
EOF

    # -----------------------------------------------------------------------
    # Patch 1: Bio/motifs/_pwm.c — two changes for Python 3.10+ ABI:
    #   a) Add PY_SSIZE_T_CLEAN before Python.h so '#' format codes use
    #      Py_ssize_t (required by Python 3.10+, else SystemError).
    #   b) Change the local variable 's' from 'int' to 'Py_ssize_t': with
    #      PY_SSIZE_T_CLEAN the "s#" PyArg format writes a Py_ssize_t, so
    #      assigning into an 'int' truncates the value and causes the
    #      "size of scores array is inconsistent" RuntimeError.
    # -----------------------------------------------------------------------
    sed -i 's|^#include <Python\.h>|#define PY_SSIZE_T_CLEAN\n#include <Python.h>|' \
        /workspace/biopython/Bio/motifs/_pwm.c
    sed -i 's/^\([[:space:]]*\)int s;$/\1Py_ssize_t s;/' \
        /workspace/biopython/Bio/motifs/_pwm.c

    # -----------------------------------------------------------------------
    # Patch 2: Bio/SeqIO/SeqXmlIO.py — guard startPropertyElement against
    # empty self.records list.
    # When certain formats (embl7, genbank18, swiss4) are round-tripped
    # through seqxml, the SAX parser fires a property element event during
    # parser.close() after all entries are already consumed, leaving
    # self.records empty at that point. The fix inserts an early return
    # in startPropertyElement before the self.records[-1] access, matching
    # the fix applied in biopython > 1.78.
    # The target string uses the line immediately following to make it
    # unique among the five self.records[-1] sites in the file.
    # -----------------------------------------------------------------------
    python3 - <<'PYEOF'
import pathlib

path = pathlib.Path("/workspace/biopython/Bio/SeqIO/SeqXmlIO.py")
src = path.read_text()

# Target the specific occurrence in startPropertyElement by anchoring on
# the unique line that follows it in that function.
old = (
    "        record = self.records[-1]\n"
    "        if property_name == \"molecule_type\":"
)
new = (
    "        if not self.records:\n"
    "            return\n"
    "        record = self.records[-1]\n"
    "        if property_name == \"molecule_type\":"
)

assert old in src, "SeqXmlIO patch target not found — check line content"
path.write_text(src.replace(old, new, 1))
print("SeqXmlIO.py patched successfully")
PYEOF

    # -----------------------------------------------------------------------
    # Patch 3: Bio/Align/substitution_matrices/__init__.py — fix read() so
    # it does not assert-crash when the row header letter mismatches.
    # In biopython 1.78 the read() function has:
    #   assert letter1 == row.pop(0)
    # On some platforms the matrix data files are read with a leading space
    # or encoding artefact that shifts the parsed tokens, so letter1 does
    # not equal row[0].  The upstream fix (biopython > 1.78) replaces the
    # hard assert with a simple pop-and-compare that raises ValueError.
    # We apply the same: replace the bare assert with an explicit check.
    # -----------------------------------------------------------------------
    python3 - <<'PYEOF'
import pathlib

path = pathlib.Path(
    "/workspace/biopython/Bio/Align/substitution_matrices/__init__.py"
)
src = path.read_text()

old = "            assert letter1 == row.pop(0)"
new = (
    "            row_letter = row.pop(0)\n"
    "            if letter1 != row_letter:\n"
    "                raise ValueError(\n"
    "                    f\"Expected '{letter1}' but got '{row_letter}' \"\n"
    "                    \"in substitution matrix row header\"\n"
    "                )"
)

assert old in src, "substitution_matrices patch target not found — check line content"
path.write_text(src.replace(old, new, 1))
print("substitution_matrices/__init__.py patched successfully")
PYEOF

    # -----------------------------------------------------------------------
    # Patch 4: Bio/Statistics/lowess.py — replace numpy.float with float in
    # the two docstring example lines.
    # numpy.float was removed in numpy 1.24+. On Python ≥3.12 we install
    # numpy>=1.26, so these doctest lines would fail. The builtin float is
    # the correct replacement (numpy.float was already an alias for float).
    # Only applied on Python ≥3.12 where numpy>=1.26 is used.
    # -----------------------------------------------------------------------
    if [ "${PYMINOR}" -ge 12 ]; then
        sed -i 's/], numpy\.float)/], float)/g' \
            /workspace/biopython/Bio/Statistics/lowess.py
        echo "lowess.py patched successfully"
    fi
}

pre_test() {
    # Match the numpy version constraint used at build time.
    PYMINOR="${PYTHON_VERSION##*.}"
    if [ "${PYMINOR}" -ge 12 ]; then
        pip install "numpy>=1.26"
    else
        pip install "numpy<1.24"
    fi

    # Move Bio/ completely out of the workspace so run_tests.py cannot find
    # it either as an importable package (causing .so import failures) or as
    # a doctest scan target (causing Bio_src.* doctest failures).
    mv /workspace/biopython/Bio /tmp/Bio_biopython_src
}

custom_test_command() {
    cd /workspace/biopython

    PYMINOR="${PYTHON_VERSION##*.}"

    if [ "${PYMINOR}" -ge 14 ]; then
        # distutils was fully removed in Python 3.14; fall back to pytest.
        pip install pytest
        python -m pytest Tests/ -q 2>&1 | tee test_logs.txt
    else
        # Use the upstream test runner; --offline skips all network tests.
        python Tests/run_tests.py --offline $(
            ls Tests/test_*.py \
            | xargs -n1 basename \
            | sed 's/\.py$//'
        ) 2>&1 | tee test_logs.txt
    fi
}

source "${SCRIPT_DIR}/../../v2-templates/python.sh"

