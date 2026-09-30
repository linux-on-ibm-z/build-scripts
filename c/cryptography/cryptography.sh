#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : cryptography
# Version       : 44.0.1
# Source repo   : https://github.com/pyca/cryptography
# Tested on     : UBI:9.7
# Language      : Python
# Script License: Apache License, Version 2 or later
# Maintainer    : Viddya K <viddya.k@ibm.com>
#
# Notes:
#   - cryptography provides low-level cryptographic primitives and recipes for Python
#   - Requires Rust/Cargo for building the Rust extension (via maturin build backend)
#   - 11 tests deselected: SHA1-based RSA/SSH/X509 operations fail with OpenSSL 3.5+ on s390x
#     ("sha1 is not supported by this backend for RSA signing") and 1 ECDSA deterministic-
#     signing failure ("evp_pkey_ctx_set_md:invalid digest").
#     See: https://github.com/pyca/cryptography/issues/11332
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="cryptography"
PACKAGE_VERSION="${1:-44.0.1}"
PACKAGE_URL="https://github.com/pyca/cryptography"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="git gcc gcc-c++ make python3-devel python3-pip openssl-devel libffi-devel cargo rust"
DEB_DEP_PKGS="git gcc g++ make python3-dev python3-pip python3-venv libssl-dev libffi-dev cargo rustc"
SLES_DEP_PKGS="git gcc gcc-c++ make python3-devel python3-pip libopenssl-devel libffi-devel cargo rust"

# =============================================================================
# CALLBACK: pre_build
# Install Rust-based build binding required by the cryptography Rust extension
# Note: Runs INSIDE .venv-build
# =============================================================================
pre_build() {
    log_info "Installing maturin build backend and build dependencies..."
    # cryptography 44+ uses maturin as its build backend (not setuptools-rust).
    # cffi is required at build time for maturin to generate Python FFI bindings.
    # The template builds with --no-isolation so these must be pre-installed.
    pip install "maturin>=1,<2" "cffi>=1.12"
}

# =============================================================================
# CALLBACK: custom_test_command
# Install test dependencies and run the test suite
# =============================================================================
custom_test_command() {
    log_info "Installing test dependencies..."
    pip install \
        "cryptography_vectors==${PACKAGE_VERSION}" \
        "pytest>=7.4.0" \
        "pytest-benchmark>=4.0" \
        "pytest-cov>=2.10.1" \
        "pytest-xdist>=3.5.0" \
        "pretend>=0.7" \
        "certifi>=2024"

    log_info "Running cryptography tests..."
    # Skip 11 tests that fail on both x86_64 and s390x with OpenSSL 3.5.5:
    #   - 10 SHA1-based RSA/SSH/X509 failures: OpenSSL 3.5+ disables SHA1 for signing
    #   - 1 ECDSA deterministic-signing failure: "evp_pkey_ctx_set_md:invalid digest"
    # Upstream issue: https://github.com/pyca/cryptography/issues/11332
    pytest \
        --deselect=tests/hazmat/primitives/test_ec.py::TestECDSAVectors::test_deterministic_nonce \
        --deselect=tests/hazmat/primitives/test_rsa.py::TestRSASignature::test_pkcs1v15_signing \
        --deselect=tests/hazmat/primitives/test_rsa.py::TestRSASignature::test_pss_signing \
        --deselect=tests/hazmat/primitives/test_rsa.py::TestRSAVerification::test_pkcs1v15_verification \
        --deselect=tests/hazmat/primitives/test_rsa.py::TestRSAVerification::test_pss_verification \
        --deselect=tests/hazmat/primitives/test_rsa.py::TestRSAPSSMGF1Verification::test_rsa_pss_mgf1_sha1 \
        --deselect=tests/hazmat/primitives/test_rsa.py::TestRSAPKCS1Verification::test_rsa_pkcs1v15_verify_sha1 \
        --deselect="tests/hazmat/primitives/test_ssh.py::TestSSHCertificate::test_verify_cert_signature[p256-rsa-sha1.pub]" \
        --deselect="tests/hazmat/primitives/test_ssh.py::TestSSHCertificate::test_invalid_signature[p256-rsa-sha1.pub]" \
        --deselect=tests/x509/test_x509.py::TestRSACertificate::test_tbs_certificate_bytes \
        --deselect=tests/x509/test_x509.py::TestRSACertificateRequest::test_tbs_certrequest_bytes
}

# =============================================================================
# Execute the build (invokes the Python template)
# =============================================================================
source "${SCRIPT_DIR}/../../templates/python.sh"
