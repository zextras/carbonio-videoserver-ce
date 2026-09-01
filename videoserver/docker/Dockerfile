# SPDX-FileCopyrightText: 2025 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

# syntax=docker/dockerfile:1.24

# Stage 1: runs natively on BUILDPLATFORM (amd64 CI builder) — no QEMU.
# carbonio-videoserver-ce / -confs-ce are prebuilt by the "Build deb/rpm"
# stage (yap: native amd64 + cross-compiled arm64) and unstashed into
# artifacts/ before this build runs (see Jenkinsfile). We fetch the
# actual runtime libs janus needs for TARGETARCH via an explicit
# `apt-get download` list (pure network fetch, no execution) and unpack
# every package with `dpkg -x` — never `dpkg -i`/`apt-get install`, so
# no maintainer scripts run (postinst does a live `curl ifconfig.me`
# call and systemctl calls that are meaningless in a container) and no
# target-arch code ever executes on the BUILDPLATFORM host.
#
# Deliberately NOT using the package's full Depends closure: it drags
# in service-discover-base -> carbonio-core -> carbonio-mailbox-jar +
# carbonio-openjdk + carbonio-mariadb + envoyproxy (466MB), none of
# which this single-process container (entrypoint just execs janus)
# ever invokes. cdebconf/debconf/dialog are postinst-only and are
# skipped for the same reason dpkg -x is used at all.
FROM --platform=$BUILDPLATFORM docker.io/library/ubuntu:resolute AS installer

ARG TARGETARCH
ARG BUILDARCH=amd64

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 # Cross-arch setup when TARGETARCH != BUILDARCH
 && if [ "${TARGETARCH}" != "${BUILDARCH}" ]; then \
      dpkg --add-architecture ${TARGETARCH} \
      && sed -i 's|^deb |deb [arch='"${BUILDARCH}"'] |' /etc/apt/sources.list \
      && printf 'Types: deb\nURIs: http://ports.ubuntu.com/ubuntu-ports/\nSuites: jammy jammy-updates jammy-security\nComponents: main restricted universe multiverse\nArchitectures: %s\nSigned-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg\n' "${TARGETARCH}" \
         > /etc/apt/sources.list.d/ports-${TARGETARCH}.sources; \
    fi \
 && printf 'deb [arch=%s trusted=yes] https://repo.area51-zextras.com/devel/ubuntu jammy main\n' "${TARGETARCH}" \
    > /etc/apt/sources.list.d/zextras.list \
 && apt-get update

COPY artifacts/ /tmp/artifacts/

# The codename must be pinned: on default-branch builds the "Upload artifacts"
# stage unstashes every distro into this same workspace before the docker build,
# so artifacts/ also holds the noble (and rocky) packages. An unpinned
# *_${TARGETARCH}.deb glob then matches two files and dpkg -x dies with exit 2.
# This image is jammy-based, so it must unpack the jammy build.
RUN set -e; \
	pkg_ce=$(ls /tmp/artifacts/carbonio-videoserver-ce_*jammy*_${TARGETARCH}.deb); \
	pkg_confs=$(ls /tmp/artifacts/carbonio-videoserver-confs-ce_*jammy*_${TARGETARCH}.deb); \
	for p in "$pkg_ce" "$pkg_confs"; do \
		[ "$(printf '%s\n' "$p" | wc -l)" -eq 1 ] || { echo "ambiguous deb match: $p" >&2; exit 1; }; \
	done; \
	mkdir -p /staging /tmp/debs && cd /tmp/debs && \
	apt-get download \
		carbonio-curl:${TARGETARCH} \
		carbonio-ffmpeg:${TARGETARCH} \
		carbonio-libnice:${TARGETARCH} \
		carbonio-libopus:${TARGETARCH} \
		carbonio-librabbitmq-c:${TARGETARCH} \
		carbonio-libsrtp:${TARGETARCH} \
		carbonio-libusrsctp:${TARGETARCH} \
		carbonio-openssl:${TARGETARCH} \
		libc6:${TARGETARCH} \
		libconfig9:${TARGETARCH} \
		libglib2.0-0:${TARGETARCH} \
		libjansson4:${TARGETARCH} \
		libmicrohttpd12:${TARGETARCH} \
		libogg0:${TARGETARCH} \
		libterm-readline-gnu-perl:${TARGETARCH} \
		zlib1g:${TARGETARCH} && \
	cd / && for deb in /tmp/debs/*.deb "$pkg_ce" "$pkg_confs"; do dpkg -x "$deb" /staging; done && \
	rm -rf /tmp/debs /tmp/artifacts /var/lib/apt/lists/*

# Janus scans this directory for logger plugins at startup; the package
# doesn't ship an empty dir (dpkg can't package one without an explicit
# `install -d`), so create it ourselves.
RUN mkdir -p /staging/opt/zextras/common/lib/janus/loggers

COPY videoserver/docker/config/janus.jcfg /staging/etc/janus/
COPY videoserver/docker/config/janus.jcfg.sample /staging/etc/janus/
COPY videoserver/docker/config/janus.eventhandler.rabbitmqevh.jcfg /staging/etc/janus/
COPY videoserver/docker/config/janus.eventhandler.rabbitmqevh.jcfg.sample /staging/etc/janus/
COPY videoserver/docker/config/janus.plugin.audiobridge.jcfg /staging/etc/janus/
COPY videoserver/docker/config/janus.plugin.audiobridge.jcfg.sample /staging/etc/janus/
COPY videoserver/docker/config/janus.plugin.videoroom.jcfg /staging/etc/janus/
COPY videoserver/docker/config/janus.plugin.videoroom.jcfg.sample /staging/etc/janus/
COPY videoserver/docker/config/janus.transport.http.jcfg /staging/etc/janus/
COPY videoserver/docker/config/janus.transport.http.jcfg.sample /staging/etc/janus/

COPY videoserver/docker/entrypoint.sh /staging/entrypoint.sh
RUN chmod +x /staging/entrypoint.sh

# Stage 2: final image — TARGETPLATFORM, zero RUN steps, no QEMU needed.
FROM --platform=$TARGETPLATFORM docker.io/library/ubuntu:resolute

COPY --from=installer /staging/ /

# WebSocket transport (port 8188) is not built into carbonio-videoserver-ce
# (PKGBUILD passes --disable-websockets), so it is not exposed here.
EXPOSE 8088 7088
EXPOSE 20000-20200/udp

ENTRYPOINT ["/entrypoint.sh"]
