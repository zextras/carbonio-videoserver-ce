# SPDX-FileCopyrightText: 2026 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

# Makefile for building carbonio-videoserver-ce packages using YAP

# Configuration
YAP_IMAGE_PREFIX  ?= docker.io/m0rf30/yap
YAP_VERSION       ?= 1.54

# Prefer podman if installed AND its machine/daemon is reachable; fall back to docker.
CONTAINER_RUNTIME ?= $(shell if command -v podman >/dev/null 2>&1 && podman info >/dev/null 2>&1; then echo podman; elif command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then echo docker; elif command -v podman >/dev/null 2>&1; then echo podman; else echo docker; fi)

# Distribution target
TARGET ?= ubuntu-jammy

# Path to carbonio-videoserver-thirds artifacts.
# Defaults to the sibling project's artifacts folder if it exists.
THIRDS_ARTIFACTS := ../carbonio-videoserver-thirds/artifacts
THIRDS_DIR ?= $(shell test -d "$(THIRDS_ARTIFACTS)" && echo "$(THIRDS_ARTIFACTS)" || echo none)

# Computed values
YAP_IMAGE   = $(YAP_IMAGE_PREFIX)-$(TARGET):$(YAP_VERSION)
CCACHE_DIR ?= $(CURDIR)/.ccache
OUTPUT_DIR ?= artifacts

# Mount the thirds directory into the container as /thirds (read-only) if provided
ifneq ($(THIRDS_DIR),none)
THIRDS_MOUNT = -v $(realpath $(THIRDS_DIR)):/thirds:ro
THIRDS_ARG   = /thirds
else
THIRDS_MOUNT =
THIRDS_ARG   = none
endif

# Auto-detect host OS: macOS uses build-macos.sh (QEMU workarounds),
# Linux uses build-linux.sh (LTO enabled, native x86_64).
HOST_OS := $(shell uname)
ifeq ($(HOST_OS),Darwin)
  BUILD_SCRIPT = /project/build-macos.sh
else
  BUILD_SCRIPT = /project/build-linux.sh
endif

# Container mount options
CONTAINER_OPTS = --rm \
	--platform linux/amd64 \
	-v $(CURDIR):/project \
	-v $(CURDIR)/$(OUTPUT_DIR):/artifacts \
	-v $(CCACHE_DIR):/root/.ccache \
	-e CCACHE_DIR=/root/.ccache \
	--entrypoint bash

.PHONY: help build build-macos build-linux pull clean list-targets list-packages

.DEFAULT_GOAL := help

## help: Show this help message
help:
	@echo "Carbonio Videoserver CE - Build System"
	@echo ""
	@echo "Usage:"
	@echo "  make <target> [TARGET=<distro>] [THIRDS_DIR=<path>]"
	@echo ""
	@echo "Targets:"
	@echo "  help           Show this help message"
	@echo "  build          Build using auto-detected host OS (macOS or Linux)"
	@echo "  build-macos    Build with QEMU workarounds (for macOS / Apple Silicon)"
	@echo "  build-linux    Build with LTO enabled    (for Linux / CI)"
	@echo "  pull           Pull the YAP container image"
	@echo "  clean          Remove build artifacts"
	@echo "  list-targets   List supported distribution targets"
	@echo "  list-packages  List all packages defined in yap.json"
	@echo ""
	@echo "Options:"
	@echo "  TARGET         Distribution target (default: ubuntu-jammy)"
	@echo "                 Supported: ubuntu-jammy, ubuntu-noble, rocky-8, rocky-9"
	@echo "  THIRDS_DIR     Path to carbonio-videoserver-thirds artifacts"
	@echo "                 (default: ../carbonio-videoserver-thirds/artifacts if it exists)"
	@echo ""
	@echo "Examples:"
	@echo "  make build                              # auto-detect host OS, auto-find thirds"
	@echo "  make build-macos TARGET=ubuntu-jammy"
	@echo "  make build-linux TARGET=ubuntu-jammy"
	@echo "  make build THIRDS_DIR=/path/to/thirds/artifacts"
	@echo ""

## build: Build packages — auto-detects host OS
build:
	@echo "==> Detected host OS: $(HOST_OS)"
	@echo "==> Thirds packages: $(THIRDS_ARG)"
	@mkdir -p $(OUTPUT_DIR) $(CCACHE_DIR)
	$(CONTAINER_RUNTIME) run $(CONTAINER_OPTS) $(THIRDS_MOUNT) $(YAP_IMAGE) \
		$(BUILD_SCRIPT) $(THIRDS_ARG) $(TARGET)

## build-macos: Build with QEMU workarounds (macOS / Apple Silicon)
build-macos:
	@echo "==> Thirds packages: $(THIRDS_ARG)"
	@mkdir -p $(OUTPUT_DIR) $(CCACHE_DIR)
	$(CONTAINER_RUNTIME) run $(CONTAINER_OPTS) $(THIRDS_MOUNT) $(YAP_IMAGE) \
		/project/build-macos.sh $(THIRDS_ARG) $(TARGET)

## build-linux: Build with LTO enabled (Linux / CI)
build-linux:
	@echo "==> Thirds packages: $(THIRDS_ARG)"
	@mkdir -p $(OUTPUT_DIR) $(CCACHE_DIR)
	$(CONTAINER_RUNTIME) run $(CONTAINER_OPTS) $(THIRDS_MOUNT) $(YAP_IMAGE) \
		/project/build-linux.sh $(THIRDS_ARG) $(TARGET)

## pull: Pull the YAP container image for the specified TARGET
pull:
	@echo "Pulling YAP image for $(TARGET)..."
	$(CONTAINER_RUNTIME) pull --platform linux/amd64 $(YAP_IMAGE)

## clean: Remove build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(OUTPUT_DIR) .ccache
	@echo "Clean complete!"

## list-targets: List supported distribution targets
list-targets:
	@echo "Supported distribution targets:"
	@echo ""
	@echo "  ubuntu-jammy    (Ubuntu 22.04 LTS)"
	@echo "  ubuntu-noble    (Ubuntu 24.04 LTS)"
	@echo "  rocky-8         (Rocky Linux 8)"
	@echo "  rocky-9         (Rocky Linux 9)"
	@echo ""
	@echo "Usage: make build TARGET=<target>"

## list-packages: List all packages defined in yap.json
list-packages:
	@echo "Packages defined in yap.json:"
	@echo ""
	@cat yap.json | grep -oP '"name":\s*"\K[^"]+' | while read pkg; do echo "  - $$pkg"; done
