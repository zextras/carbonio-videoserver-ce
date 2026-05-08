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

# Set up base tools and Zextras apt repo
echo "==> Installing base tools"
apt-get update -qq
apt-get install -y -qq gnupg2 ca-certificates

echo "==> Setting up public Zextras repository"
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 52FD40243E584A21
echo "deb https://repo.zextras.io/release/ubuntu jammy main" > /etc/apt/sources.list.d/zextras.list
apt-get update -qq

# Install locally built thirds packages (they override any versions from the repo)
if [ "$THIRDS_DIR" != "none" ] && [ -n "$THIRDS_DIR" ]; then
    echo "==> Installing thirds packages from $THIRDS_DIR"
    find "$THIRDS_DIR" -name '*.deb' -exec dpkg -i {} + || apt-get install -f -y
    echo "==> Thirds packages installed"
fi

# Prepare yap build environment
echo "==> Running yap prepare $DISTRO -g"
yap prepare "$DISTRO" -g

# Build all packages
echo "==> Running yap build $DISTRO /project"
yap build "$DISTRO" "/project"

echo "==> Build complete!"
