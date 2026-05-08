#!/bin/bash

# SPDX-FileCopyrightText: 2026 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

set -e

# This script runs INSIDE the container for macOS / Apple Silicon hosts.
# It sets up the Zextras repo, installs thirds packages, and applies QEMU
# workarounds (janus tarball pre-downloaded) needed when running an amd64
# container via Rosetta/QEMU.
#
# Usage (inside container): ./build-macos.sh <thirds-dir|none> <distro>

THIRDS_DIR=$1
DISTRO=$2

if [ -z "$DISTRO" ]; then
    echo "Usage: $0 <thirds-dir|none> <distro>"
    exit 1
fi

echo "==> Building carbonio-videoserver-ce for $DISTRO"

# Set up base tools and Zextras apt repo
echo "==> Installing base tools"
apt-get update -qq
apt-get install -y -qq gnupg2 ca-certificates curl

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

# Work on a copy of the project so that local patches never touch host files
BUILD_DIR=$(mktemp -d)
echo "==> Copying project to $BUILD_DIR"
cp -r /project/. "$BUILD_DIR/"

# Pre-download sources that trigger TLS "bad record MAC" with yap's Go HTTP client
# under QEMU emulation (amd64 on Apple Silicon). curl handles TLS correctly.
# yap caches downloads at: buildDir + "/" + package_project_path + "/" + filename
# i.e. /tmp/videoserver/<pkg>/<file>
echo "==> Pre-downloading sources prone to QEMU TLS issues (using curl)"
mkdir -p /tmp/videoserver/videoserver/
curl -L --retry 3 --retry-delay 2 \
    -o /tmp/videoserver/videoserver/v1.4.0.tar.gz \
    "https://github.com/meetecho/janus-gateway/archive/refs/tags/v1.4.0.tar.gz"

# Prepare yap build environment
echo "==> Running yap prepare $DISTRO -g"
yap prepare "$DISTRO" -g

# Build all packages from the copy
echo "==> Running yap build $DISTRO $BUILD_DIR"
yap build "$DISTRO" "$BUILD_DIR"

echo "==> Build complete!"
