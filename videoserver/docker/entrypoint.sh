#!/bin/bash

# SPDX-FileCopyrightText: 2026 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

JANUS_CFG="/etc/janus/janus.jcfg"
RABBITMQ_EVH_CFG="/etc/janus/janus.eventhandler.rabbitmqevh.jcfg"

# a jcfg string inside a sed replacement, as in carbonio-videoserver-configs
escape_string() {
	printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/[\\&|]/\\&/g'
}

# api-secret: the value k3d stores in Consul for ws-collaboration
sed "s|\${API_SECRET}|$(escape_string "${API_SECRET:-api-secret}")|" "$JANUS_CFG.sample" >"$JANUS_CFG"
sed -e "s|<RABBITMQ_USERNAME>|$(escape_string "${RABBITMQ_USERNAME:-guest}")|" \
	-e "s|<RABBITMQ_PASSWORD>|$(escape_string "${RABBITMQ_PASSWORD:-guest}")|" \
	"$RABBITMQ_EVH_CFG.sample" >"$RABBITMQ_EVH_CFG"
sed -i 's|^\(\s*\(admin_\)\{0,1\}ip = \)"127.0.0.1"|\1"0.0.0.0"|' /etc/janus/janus.transport.http.jcfg

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

if [ -n "$NAT_IP" ]; then
	sed -i "s|\${PUBLIC_IP_ADDRESS}|$NAT_IP|" "$JANUS_CFG"
	echo "nat_1_1_mapping set to: $NAT_IP"
else
	sed -i "s|^\(\s*\)nat_1_1_mapping = .*|\1#nat_1_1_mapping = \"\"|" "$JANUS_CFG"
	echo "Warning: NAT_IP is not set, nat_1_1_mapping will not be configured"
fi

# Media ports janus hands out in its candidates. Under an orchestrator only the
# ports published on the node are reachable, so this has to match what the pod
# publishes — hence the override.
RTP_PORT_RANGE="${RTP_PORT_RANGE:-20000-20200}"
sed -i "s|^\(\s*rtp_port_range = \)\".*\"|\1\"${RTP_PORT_RANGE}\"|" "$JANUS_CFG"
echo "rtp_port_range set to: $RTP_PORT_RANGE"

exec /opt/zextras/common/bin/janus
