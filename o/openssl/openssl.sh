#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : openssl
# Version       : openssl-3.0.14
# Source repo   : https://github.com/openssl/openssl
# Tested on     : UBI 9.6
# Language      : Python
# Script License: Apache-2.0
# Maintainer    : Purva
#
# Notes:
#   - Tier 0 artifact (no artifact dependencies)
#   - OpenSSL git tags use the format "openssl-X.Y.Z"
#   - Does NOT use CMake or GNU autotools. OpenSSL has its own Perl-based
#     "Configure" script (capital C) that takes an explicit target name.
#     For native s390x Linux builds the correct target is "linux64-s390x"
#     (confirmed against OpenJDK, ClickHouse, and OpenSSL's own CI configs --
#     "linux-s390x" and "linux32-s390x" are different, 32-bit-oriented
#     targets and would be wrong here).
#   - Configure's "shared" argument builds shared libraries (libssl.so,
#     libcrypto.so) in addition to the static ones.
#   - "make install_sw" installs libraries/headers/binaries only, skipping
#     man-page/doc installation, which is slower and not needed for an
#     artifact-only build.
#   - Requires Perl's IPC::Cmd module (perl-IPC-Cmd), which Configure uses
#     internally and which is not always present by default -- a common
#     silent-failure point if missing.
#   - Wrapped as a Python wheel following the cfitsio.sh pattern (a C
#     library with no native Python bindings, packaged so it's importable
#     and its files are installed under site-packages)
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="openssl"
PACKAGE_VERSION="openssl-3.0.14"
PACKAGE_URL="https://github.com/openssl/openssl"

# =============================================================================
# Artifact Declaration (Tier 0 - no artifact dependencies)
# =============================================================================
PROVIDES_ARTIFACT="openssl"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="perl perl-IPC-Cmd perl-Pod-Html gcc gcc-c++ make zlib-devel python3-devel python3-pip"
DEB_DEP_PKGS="perl gcc g++ make zlib1g-dev python3-dev python3-pip python3-venv"
SLES_DEP_PKGS="perl gcc gcc-c++ make zlib-devel python3-devel python3-pip"

# =============================================================================
# Build Configuration
# =============================================================================
LICENSE_SPDX="Apache-2.0"

# openssl is a pure C library; we build and wrap it ourselves as a wheel
# (see custom_install), so there's no upstream Python test suite to run.
SKIP_TESTS="true"

# =============================================================================
# custom_install: Build via OpenSSL's own Configure script, then wrap as a
# Python wheel
# =============================================================================
custom_install() {
    local ARTIFACT_DIR
    ARTIFACT_DIR="$(artifact_dir "${PROVIDES_ARTIFACT}" "${PACKAGE_VERSION}")"

    if [[ -f "${ARTIFACT_DIR}/env.sh" ]]; then
        log_info "Artifact already exists at ${ARTIFACT_DIR}"
        return 0
    fi

    pip install --upgrade wheel build setuptools

    log_info "Configuring OpenSSL for linux64-s390x..."
    ./Configure linux64-s390x shared \
        --prefix="${ARTIFACT_DIR}" \
        --openssldir="${ARTIFACT_DIR}/ssl" \
        no-tests

    log_info "Building OpenSSL (this takes a while)..."
    make -j"$(nproc)"

    log_info "Installing OpenSSL (libraries, headers, binaries only -- no docs)..."
    make install_sw

    log_info "OpenSSL C library installed to ${ARTIFACT_DIR}"

    # =========================================================================
    # Wrap the installed library as a Python wheel
    # =========================================================================
    # Strip the 'openssl-' tag prefix to get a valid Python package version
    # (e.g. openssl-3.0.14 -> 3.0.14)
    local PKG_VERSION_CLEAN="${PACKAGE_VERSION#openssl-}"

    local PYTHON_PKG_DIR="${SCRIPT_DIR}/python_pkg"
    rm -rf "${PYTHON_PKG_DIR}"
    mkdir -p "${PYTHON_PKG_DIR}/${PACKAGE_NAME}"

    # Copy installed library tree into the Python package directory
    cp -r "${ARTIFACT_DIR}/." "${PYTHON_PKG_DIR}/${PACKAGE_NAME}/"

    # Python package init -- expose __version__ for easy verification
    cat > "${PYTHON_PKG_DIR}/${PACKAGE_NAME}/__init__.py" << EOF
__version__ = "${PKG_VERSION_CLEAN}"
EOF

    # Copy license
    if [[ -f "${SCRIPT_DIR}/LICENSE" ]]; then
        cp "${SCRIPT_DIR}/LICENSE" "${PYTHON_PKG_DIR}/LICENSE"
    fi

    log_info "Generating Python packaging files..."

    # setup.py -- copies library tree into site-packages on install
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

    # Install the wheel so tests can import openssl and resolve library paths
    pip install "${PYTHON_PKG_DIR}/dist/"*.whl

    local OPENSSL_BASE
    OPENSSL_BASE="$(python3 -c "import openssl, os; print(os.path.dirname(openssl.__file__))")"
    export LD_LIBRARY_PATH="${OPENSSL_BASE}/lib64:${OPENSSL_BASE}/lib:${LD_LIBRARY_PATH:-}"
    export PKG_CONFIG_PATH="${OPENSSL_BASE}/lib64/pkgconfig:${OPENSSL_BASE}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
    export PATH="${OPENSSL_BASE}/bin:${PATH}"

    # =========================================================================
    # Generate env.sh for downstream artifact consumers
    # =========================================================================
    cat > "${ARTIFACT_DIR}/env.sh" << INNER_EOF
# openssl ${PACKAGE_VERSION} environment
export OPENSSL_PREFIX="${ARTIFACT_DIR}"
export PATH="${ARTIFACT_DIR}/bin:\${PATH}"
export LD_LIBRARY_PATH="${ARTIFACT_DIR}/lib64:${ARTIFACT_DIR}/lib:\${LD_LIBRARY_PATH:-}"
export PKG_CONFIG_PATH="${ARTIFACT_DIR}/lib64/pkgconfig:${ARTIFACT_DIR}/lib/pkgconfig:\${PKG_CONFIG_PATH:-}"
export OPENSSL_DIR="${ARTIFACT_DIR}"
INNER_EOF

    generate_artifact_manifest "${ARTIFACT_DIR}" \
        "${PROVIDES_ARTIFACT}" "${PACKAGE_VERSION}" \
        "${PACKAGE_URL}" "${LICENSE_SPDX}"

    log_info "openssl installed to ${ARTIFACT_DIR}"
}

# =============================================================================
# Execute the build (invokes the Python template)
# =============================================================================
source "${SCRIPT_DIR}/../../v2-templates/python.sh"
