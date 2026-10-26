#!/bin/bash -e
# -----------------------------------------------------------------------------
# Package       : cfssl
# Version       : v1.6.2
# Source repo   : https://github.com/cloudflare/cfssl/
# Tested on     : UBI 9.3
# Language      : Go
# Script License: Apache License, Version 2 or later
# Maintainer    : Srighakollapu-Srivatsa1 <Srighakollapu.Srivatsa1@ibm.com>
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# REQUIRED: Package metadata
# =============================================================================
PACKAGE_NAME="cfssl"
PACKAGE_VERSION="${1:-v1.6.2}"
PACKAGE_URL="https://github.com/cloudflare/cfssl/"

# =============================================================================
# REQUIRED: Dependencies
# =============================================================================
RH_DEP_PKGS="gcc-c++ git make wget"
DEB_DEP_PKGS=""
SLES_DEP_PKGS=""

# =============================================================================
# OPTIONAL: Custom environment variables (from original script)
# =============================================================================
export GOFLAGS="-mod=vendor"
export GODEBUG="x509sha1=1"

# REVIEW - following code was not auto-migrated. See PORTING-NOTES.md for details.
# GO_VERSION=go1.26.4
# rm -rf /bin/go
# wget https://go.dev/dl/$GO_VERSION.linux-s390x.tar.gz
# tar -C /bin -xzf $GO_VERSION.linux-s390x.tar.gz
# rm -f $GO_VERSION.linux-s390x.tar.gz
# export PATH=$PATH:/bin/go/bin
# export GOPATH=/home/tester/go
# mkdir -p /home/tester/go
# cd $GOPATH
# mkdir -p $GOPATH/src/github.com/cloudflare
# cd $GOPATH/src/github.com/cloudflare
# export GOFLAGS="-mod=vendor"
# export GODEBUG="x509sha1=1"
# chmod +x test.sh
# if ! ./test.sh; then

# =============================================================================
# Execute the build (invokes the Go template)
# =============================================================================
source "${SCRIPT_DIR}/../../templates/go.sh"
