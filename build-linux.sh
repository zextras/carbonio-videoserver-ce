#!/bin/bash

# SPDX-FileCopyrightText: 2026 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

set -e

# This script runs INSIDE the container on real x86_64 hardware (Linux CI).
# LTO is enabled and no QEMU workarounds are applied.
#
# Usage (inside container): ./build-linux.sh <thirds-dir|none> <distro>

THIRDS_DIR=$1
DISTRO=$2

if [ -z "$DISTRO" ]; then
    echo "Usage: $0 <thirds-deps-dir|none> <distro>"
    exit 1
fi

echo "==> Building carbonio-videoserver-ce for $DISTRO"

# Detect package manager family
if [ -f /etc/debian_version ]; then
    PKG_FAMILY="debian"
elif [ -f /etc/redhat-release ]; then
    PKG_FAMILY="rhel"
else
    echo "Error: Unknown Linux distribution in container"
    exit 1
fi

echo "==> Setting up public Zextras repository (PKG_FAMILY=$PKG_FAMILY)"
if [ "$PKG_FAMILY" = "debian" ]; then
    apt-get update -qq
    apt-get install -y -qq gnupg2 ca-certificates
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 52FD40243E584A21
    UBUNTU_CODENAME="${DISTRO#ubuntu-}"
    echo "deb https://repo.zextras.io/release/ubuntu ${UBUNTU_CODENAME} main" > /etc/apt/sources.list.d/zextras.list
    apt-get update -qq
else
    dnf install -y -q ca-certificates 2>/dev/null || true
    case "$DISTRO" in
        rocky-8) RHEL_REPO="rhel8" ;;
        rocky-9) RHEL_REPO="rhel9" ;;
        *) echo "Error: Unknown RHEL distro variant: $DISTRO"; exit 1 ;;
    esac
    cat > /etc/yum.repos.d/zextras.repo <<EOF
[zextras]
name=Zextras
baseurl=https://repo.zextras.io/release/${RHEL_REPO}/
enabled=1
gpgcheck=0
EOF
fi

# Install locally built thirds packages (they override any versions from the repo)
if [ "$THIRDS_DIR" != "none" ] && [ -n "$THIRDS_DIR" ]; then
    echo "==> Installing thirds packages from $THIRDS_DIR"
    if [ "$PKG_FAMILY" = "debian" ]; then
        find "$THIRDS_DIR" -name '*.deb' -exec dpkg -i {} + || apt-get install -f -y
    else
        find "$THIRDS_DIR" -name '*.rpm' -print0 | xargs -0 dnf install -y
    fi
    echo "==> Thirds packages installed"
fi

# Prepare yap build environment
echo "==> Running yap prepare $DISTRO -g"
yap prepare "$DISTRO" -g

# Build all packages
echo "==> Running yap build $DISTRO /project"
yap build "$DISTRO" "/project"

echo "==> Build complete!"
