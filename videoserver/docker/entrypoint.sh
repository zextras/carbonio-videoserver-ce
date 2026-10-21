#!/bin/bash

# SPDX-FileCopyrightText: 2026 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

JANUS_CFG="/etc/janus/janus.jcfg"
RABBITMQ_EVH_CFG="/etc/janus/janus.eventhandler.rabbitmqevh.jcfg"

# Defaults keep the plain compose setup working (container DNS to the broker).
# Point these at the consul sidecar upstream (127.0.0.1:20001, as on bare metal)
# to go through the mesh instead.
RABBITMQ_HOST="${RABBITMQ_HOST:-carbonio-message-broker}"
RABBITMQ_PORT="${RABBITMQ_PORT:-10000}"

sed -i \
	-e "s|^\(\s*host = \)\".*\"|\1\"${RABBITMQ_HOST}\"|" \
	-e "s|^\(\s*port = \)[0-9]*|\1${RABBITMQ_PORT}|" \
	"$RABBITMQ_EVH_CFG"
echo "rabbitmq event handler set to: ${RABBITMQ_HOST}:${RABBITMQ_PORT}"

# janus keeps running without its event handler if the broker is unreachable at
# startup, so nobody notices the missing events; through the mesh the upstream
# also only exists once the sidecar's envoy is up. Same reason the packaged unit
# has carbonio-message-broker-consul-check as ExecStartPre.
#
# A plain TCP connect is not enough: envoy accepts on the upstream port whether
# or not the broker behind it is serving. Sending the AMQP header and waiting for
# a reply is what tells the two apart. Subshell so a failed redirect can't take
# the script down with it.
broker_speaks_amqp() {
	(
		exec 3<>"/dev/tcp/${RABBITMQ_HOST}/${RABBITMQ_PORT}" &&
			printf 'AMQP\x00\x00\x09\x01' >&3 &&
			read -r -t 2 -N 1 _ <&3
	) 2>/dev/null
}

for _ in $(seq 1 30); do
	broker_speaks_amqp && break
	echo "waiting for rabbitmq at ${RABBITMQ_HOST}:${RABBITMQ_PORT}..."
	sleep 2
done

if [ -n "$NAT_IP" ]; then
	sed -i "s|#nat_1_1_mapping = .*|nat_1_1_mapping = \"$NAT_IP\"|" "$JANUS_CFG"
	echo "nat_1_1_mapping set to: $NAT_IP"
else
	echo "Warning: NAT_IP is not set, nat_1_1_mapping will not be configured"
fi

# Media ports janus hands out in its candidates. Under an orchestrator only the
# ports published on the node are reachable, so this has to match what the pod
# publishes — hence the override.
if [ -n "$RTP_PORT_RANGE" ]; then
	sed -i "s|^\(\s*rtp_port_range = \)\".*\"|\1\"${RTP_PORT_RANGE}\"|" "$JANUS_CFG"
	echo "rtp_port_range set to: $RTP_PORT_RANGE"
fi

exec /opt/zextras/common/bin/janus
