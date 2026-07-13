#!/bin/sh

# SPDX-FileCopyrightText: 2026 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

JANUS_CFG="/etc/janus/janus.jcfg"

if [ -n "$NAT_IP" ]; then
	sed -i "s|#nat_1_1_mapping = .*|nat_1_1_mapping = \"$NAT_IP\"|" "$JANUS_CFG"
	echo "nat_1_1_mapping set to: $NAT_IP"
else
	echo "Warning: NAT_IP is not set, nat_1_1_mapping will not be configured"
fi

exec /opt/zextras/common/bin/janus
