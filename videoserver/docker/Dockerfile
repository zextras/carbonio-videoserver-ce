# SPDX-FileCopyrightText: 2025 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

# 🧱 Fase 1: Build
FROM debian:trixie AS builder

RUN apt-get -y update && \
	apt-get install -y \
	libavutil-dev libavformat-dev libavcodec-dev libmicrohttpd-dev \
	libjansson-dev libssl-dev libsofia-sip-ua-dev libglib2.0-dev \
	libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev \
	libconfig-dev libusrsctp-dev libwebsockets-dev libnanomsg-dev \
	librabbitmq-dev pkg-config gengetopt libtool automake \
	build-essential wget git gtk-doc-tools && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

# Libsrtp
RUN cd /tmp && \
	wget https://github.com/cisco/libsrtp/archive/v2.3.0.tar.gz && \
	tar xfv v2.3.0.tar.gz && cd libsrtp-2.3.0 && \
	./configure --prefix=/usr --enable-openssl && \
	make shared_library && make install

# Libnice
RUN cd /tmp && \
	git clone https://gitlab.freedesktop.org/libnice/libnice && \
	cd libnice && git checkout 0.1.17 && \
	./autogen.sh && ./configure --prefix=/usr && \
	make && make install

# Janus build
RUN cd /usr/local/src && \
	git clone --branch v1.2.4 --depth 1 https://github.com/meetecho/janus-gateway.git

RUN cd /usr/local/src/janus-gateway && \
	sh autogen.sh && \
	./configure \
	--disable-all-handlers \
	--disable-all-plugins \
	--disable-all-transports \
	--disable-docs \
	--disable-json-logger \
	--disable-turn-rest-api \
	--enable-plugin-audiobridge \
	--enable-plugin-videoroom \
	--enable-post-processing \
	--enable-rabbitmq \
	--enable-rabbitmq-event-handler \
	--enable-rest \
	--enable-websockets \
	--enable-websockets-event-handler && \
	make -j$(nproc) && make install && make configs


FROM builder AS runtime

COPY videoserver/docker/config/janus.jcfg /usr/local/etc/janus/
COPY videoserver/docker/config/janus.jcfg.sample /usr/local/etc/janus/
COPY videoserver/docker/config/janus.eventhandler.rabbitmqevh.jcfg /usr/local/etc/janus/
COPY videoserver/docker/config/janus.eventhandler.rabbitmqevh.jcfg.sample /usr/local/etc/janus/
COPY videoserver/docker/config/janus.plugin.audiobridge.jcfg /usr/local/etc/janus/
COPY videoserver/docker/config/janus.plugin.audiobridge.jcfg.sample /usr/local/etc/janus/
COPY videoserver/docker/config/janus.plugin.videoroom.jcfg /usr/local/etc/janus/
COPY videoserver/docker/config/janus.plugin.videoroom.jcfg.sample /usr/local/etc/janus/
COPY videoserver/docker/config/janus.transport.http.jcfg /usr/local/etc/janus/
COPY videoserver/docker/config/janus.transport.http.jcfg.sample /usr/local/etc/janus/
COPY videoserver/docker/config/janus.transport.websockets.jcfg /usr/local/etc/janus/
COPY videoserver/docker/config/janus.transport.websockets.jcfg.sample /usr/local/etc/janus/

RUN mkdir -p /usr/local/lib/janus/loggers

EXPOSE 8088 7088 8188
EXPOSE 10000-10200/udp
CMD ["/usr/local/bin/janus"]