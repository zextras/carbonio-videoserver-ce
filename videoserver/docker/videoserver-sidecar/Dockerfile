# SPDX-FileCopyrightText: 2026 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

ARG SIDECAR_IMAGE=registry.dev.zextras.com/dev/carbonio-sidecar:main

FROM --platform=$BUILDPLATFORM docker.io/library/alpine:3.23 AS consul-template
ARG TARGETARCH
ARG CONSUL_TEMPLATE_VERSION=0.42.1
RUN apk add --no-cache curl unzip && \
    curl -fsSL -o /tmp/ct.zip "https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_${TARGETARCH}.zip" && \
    curl -fsSL -o /tmp/ct.sums "https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS" && \
    echo "$(grep "_linux_${TARGETARCH}.zip" /tmp/ct.sums | cut -d' ' -f1)  /tmp/ct.zip" | sha256sum -c - && \
    unzip -j /tmp/ct.zip consul-template -d /out && \
    chmod +x /out/consul-template

FROM ${SIDECAR_IMAGE}

# Service registration (registered by the base entrypoint)
COPY --from=consul-template /out/consul-template /usr/local/bin/consul-template
COPY videoserver/videoserver/carbonio-videoserver-template.hcl /consul/templates/carbonio-videoserver-template.hcl

# Setup files
COPY videoserver/videoserver/service-protocol.json /etc/carbonio/videoserver/service-discover/
COPY videoserver/videoserver/intentions.json       /etc/carbonio/videoserver/service-discover/
COPY videoserver/videoserver/policies.json         /etc/carbonio/videoserver/service-discover/

# COPY --chmod avoids a target-arch RUN (QEMU-free)
COPY --chmod=755 videoserver/docker/videoserver-sidecar/carbonio-videoserver-setup /usr/local/bin/carbonio-videoserver-setup

ENV SERVICE_NAME=carbonio-videoserver
ENV SETUP_SCRIPT="carbonio-videoserver-setup"
ENV TOKEN_FILE=/etc/carbonio/videoserver/service-discover/token

COPY --chmod=755 videoserver/docker/videoserver-sidecar/carbonio-videoserver-hcl-entrypoint /usr/local/bin/carbonio-videoserver-hcl-entrypoint
ENTRYPOINT ["carbonio-videoserver-hcl-entrypoint"]
