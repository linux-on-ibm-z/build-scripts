#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : cfitsio
# Version       : 4.6.4
# Source repo   : https://github.com/HEASARC/cfitsio
# Tested on     : UBI:9.6
# Language      : C
# Script License: Apache License, Version 2 or later
# Maintainer    : Viddya K <viddya.k@ibm.com>
#
# Notes:
#   - Tier 0 artifact (no artifact dependencies)
#   - CFITSIO is a C library for reading/writing FITS format data files
#   - Requires bzip2 (installed via pip) for bzip2 compression support
#   - Built via ./configure + make; wrapped as a Python wheel for distribution
#   - Uses --enable-reentrant for thread-safe operation
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="cfitsio"
PACKAGE_VERSION="${1:-cfitsio-4.6.4}"
PACKAGE_URL="https://github.com/HEASARC/cfitsio"

# =============================================================================
# Artifact Declaration (Tier 0 - no artifact dependencies)
# =============================================================================
PROVIDES_ARTIFACT="cfitsio"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git gcc gcc-c++ make curl-devel zlib-devel bzip2-devel python3-devel python3-pip"
DEB_DEP_PKGS="git gcc g++ make libcurl4-openssl-dev zlib1g-dev libbz2-dev python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="git gcc gcc-c++ make libcurl-devel zlib-devel libbz2-devel python3-devel python3-pip"

# =============================================================================
# Build Configuration
# =============================================================================
LICENSE_SPDX="CFITSIO"

# =============================================================================
# custom_install: Build C library and wrap as Python wheel
# =============================================================================
custom_install() {
    local ARTIFACT_DIR
    ARTIFACT_DIR="$(artifact_dir "${PROVIDES_ARTIFACT}" "${PACKAGE_VERSION}")"

    if [[ -f "${ARTIFACT_DIR}/env.sh" ]]; then
        log_info "Artifact already exists at ${ARTIFACT_DIR}"
        return 0
    fi

    # bzip2 is provided by the bzip2-devel system package (in RH_DEP_PKGS above).
    # configure will locate it automatically via --with-bzip2.
    pip install --upgrade wheel build setuptools

    log_info "Building cfitsio C library..."
    mkdir -p "${ARTIFACT_DIR}"

    # Configure: install into ARTIFACT_DIR, enable bzip2 + reentrant (thread-safe)
    ./configure \
        --prefix="${ARTIFACT_DIR}" \
        --with-bzip2 \
        --enable-reentrant

    # Build all targets (shared lib + utilities).
    # NOTE: cfitsio 4.x uses automake; the old 'make shared utils' targets no
    # longer exist. Plain 'make' builds the shared library and all utilities.
    make -j"$(nproc)"
    make install

    log_info "cfitsio C library installed to ${ARTIFACT_DIR}"

    # =========================================================================
    # Wrap the installed library as a Python wheel
    # =========================================================================
    # Strip the 'cfitsio-' tag prefix to get a valid Python package version
    # (e.g. cfitsio-4.6.4 -> 4.6.4)
    local PKG_VERSION_CLEAN="${PACKAGE_VERSION#cfitsio-}"

    local PYTHON_PKG_DIR="${SCRIPT_DIR}/python_pkg"
    rm -rf "${PYTHON_PKG_DIR}"
    mkdir -p "${PYTHON_PKG_DIR}/${PACKAGE_NAME}"

    # Copy installed library tree into the Python package directory
    cp -r "${ARTIFACT_DIR}/." "${PYTHON_PKG_DIR}/${PACKAGE_NAME}/"

    # Python package init — expose __version__ for easy verification
    cat > "${PYTHON_PKG_DIR}/${PACKAGE_NAME}/__init__.py" << EOF
__version__ = "${PKG_VERSION_CLEAN}"
EOF

    # Copy license
    if [[ -f "License.txt" ]]; then
        cp "License.txt" "${PYTHON_PKG_DIR}/LICENSE.txt"
    fi

    log_info "Generating Python packaging files..."

    # setup.py — copies library tree into site-packages on install
    cat > "${PYTHON_PKG_DIR}/setup.py" << EOF
from setuptools import setup, find_packages
from setuptools.command.install import install
import os
from shutil import copytree

class InstallWithLibs(install):
    def run(self):
        install.run(self)
        lib_src = os.path.join(os.path.dirname(__file__), "${PACKAGE_NAME}")
        lib_dst = os.path.join(self.install_lib, "${PACKAGE_NAME}")
        copytree(lib_src, lib_dst, dirs_exist_ok=True)

setup(
    name="${PACKAGE_NAME}",
    version="${PKG_VERSION_CLEAN}",
    packages=find_packages(),
    include_package_data=True,
    cmdclass={"install": InstallWithLibs},
)
EOF

    cat > "${PYTHON_PKG_DIR}/pyproject.toml" << EOF
[build-system]
requires = ["setuptools", "wheel"]
build-backend = "setuptools.build_meta"
EOF

    cat > "${PYTHON_PKG_DIR}/MANIFEST.in" << EOF
recursive-include ${PACKAGE_NAME} *
EOF

    log_info "Building Python wheel..."
    cd "${PYTHON_PKG_DIR}"
    python setup.py bdist_wheel

    # Copy the wheel into dist/ in the source tree so the template's
    # wheel-processing logic (auditwheel, SBOM) can pick it up
    mkdir -p "${OLDPWD}/dist"
    cp dist/*.whl "${OLDPWD}/dist/"
    cd "${OLDPWD}"

    # Install the wheel so tests can import cfitsio and resolve library paths
    pip install "${PYTHON_PKG_DIR}/dist/"*.whl

    # Set env vars for the test phase (within this build session)
    local CFITSIO_BASE
    CFITSIO_BASE="$(python3 -c "import cfitsio, os; print(os.path.dirname(cfitsio.__file__))")"
    export CFITSIO_BIN="${CFITSIO_BASE}/bin"
    export CFITSIO_LIB="${CFITSIO_BASE}/lib"
    export CFITSIO_INCLUDE="${CFITSIO_BASE}/include"
    export CFLAGS="-I${CFITSIO_INCLUDE} ${CFLAGS:-}"
    export LDFLAGS="-L${CFITSIO_LIB} ${LDFLAGS:-}"
    export LIBRARY_PATH="${CFITSIO_LIB}:${LIBRARY_PATH:-}"
    export LD_LIBRARY_PATH="${CFITSIO_LIB}:${LD_LIBRARY_PATH:-}"
    export PKG_CONFIG_PATH="${CFITSIO_LIB}/pkgconfig:${PKG_CONFIG_PATH:-}"
    export PATH="${CFITSIO_BIN}:${PATH}"

    # =========================================================================
    # Generate env.sh for downstream artifact consumers
    # =========================================================================
    cat > "${ARTIFACT_DIR}/env.sh" << EOF
# cfitsio ${PACKAGE_VERSION} environment
# Generated by build script

export CFITSIO_PREFIX="${ARTIFACT_DIR}"
export PATH="${ARTIFACT_DIR}/bin:\${PATH}"
export LD_LIBRARY_PATH="${ARTIFACT_DIR}/lib:\${LD_LIBRARY_PATH:-}"
export LIBRARY_PATH="${ARTIFACT_DIR}/lib:\${LIBRARY_PATH:-}"
export CFLAGS="-I${ARTIFACT_DIR}/include \${CFLAGS:-}"
export LDFLAGS="-L${ARTIFACT_DIR}/lib \${LDFLAGS:-}"
export CPATH="${ARTIFACT_DIR}/include:\${CPATH:-}"
export PKG_CONFIG_PATH="${ARTIFACT_DIR}/lib/pkgconfig:\${PKG_CONFIG_PATH:-}"
export CMAKE_PREFIX_PATH="${ARTIFACT_DIR}:\${CMAKE_PREFIX_PATH:-}"
EOF

    # Generate artifact manifest
    generate_artifact_manifest "${ARTIFACT_DIR}" \
        "${PROVIDES_ARTIFACT}" "${PACKAGE_VERSION}" \
        "${PACKAGE_URL}" "${LICENSE_SPDX}"

    log_info "cfitsio installed to ${ARTIFACT_DIR}"
}

# =============================================================================
# custom_test_command: Run upstream cfitsio test suite
# =============================================================================
custom_test_command() {
    log_info "Setting up environment for cfitsio tests..."
    # bzip2 is a system library (bzip2-devel); no extra path setup needed.

    # Re-source cfitsio paths from the installed Python wheel
    local CFITSIO_BASE
    CFITSIO_BASE="$(python3 -c "import cfitsio, os; print(os.path.dirname(cfitsio.__file__))")"
    export CFITSIO_LIB="${CFITSIO_BASE}/lib"
    export CFITSIO_INCLUDE="${CFITSIO_BASE}/include"
    export CFITSIO_BIN="${CFITSIO_BASE}/bin"
    export CFLAGS="-I${CFITSIO_INCLUDE} ${CFLAGS:-}"
    export LDFLAGS="-L${CFITSIO_LIB} ${LDFLAGS:-}"
    export LIBRARY_PATH="${CFITSIO_LIB}:${LIBRARY_PATH:-}"
    export LD_LIBRARY_PATH="${CFITSIO_LIB}:${LD_LIBRARY_PATH:-}"
    export PATH="${CFITSIO_BIN}:${PATH}"

    log_info "Running cfitsio upstream utility tests..."

    # Run upstream utilities built as part of 'make shared utils'
    cookbook
    speed

    log_info "Running TestProg regression test..."
    ./build/TestProg > testprog.lis
    diff testprog.lis testprog.out
    cmp testprog.fit testprog.std
    log_info "TestProg output:"
    cat testprog.lis

    log_info "All cfitsio tests passed."
}

# =============================================================================
# Source the Python template to execute the build workflow
# =============================================================================
source "${SCRIPT_DIR}/../../templates/python.sh"
