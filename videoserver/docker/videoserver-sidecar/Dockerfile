# SPDX-FileCopyrightText: 2026 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

ARG SIDECAR_IMAGE=registry.dev.zextras.com/dev/carbonio-sidecar:main

FROM --platform=$BUILDPLATFORM docker.io/library/alpine:3.20 AS hcl
COPY videoserver/videoserver/carbonio-videoserver-template.hcl /carbonio-videoserver-template.hcl
RUN sed -E 's/\{\{ or \(env "[A-Z0-9_]+"\) "([^"]*)" \}\}/\1/g' \
    /carbonio-videoserver-template.hcl > /carbonio-videoserver.hcl \
    && ! grep -q '{{' /carbonio-videoserver.hcl

FROM ${SIDECAR_IMAGE}

# Service registration (registered by the base entrypoint)
COPY --from=hcl /carbonio-videoserver.hcl /consul/config/

# Setup files
COPY videoserver/videoserver/service-protocol.json /etc/carbonio/videoserver/service-discover/
COPY videoserver/videoserver/intentions.json       /etc/carbonio/videoserver/service-discover/
COPY videoserver/videoserver/policies.json         /etc/carbonio/videoserver/service-discover/

# COPY --chmod avoids a target-arch RUN (QEMU-free)
COPY --chmod=755 videoserver/docker/videoserver-sidecar/carbonio-videoserver-setup /usr/local/bin/carbonio-videoserver-setup

ENV SERVICE_NAME=carbonio-videoserver
ENV SETUP_SCRIPT="carbonio-videoserver-setup"
ENV TOKEN_FILE=/etc/carbonio/videoserver/service-discover/token
