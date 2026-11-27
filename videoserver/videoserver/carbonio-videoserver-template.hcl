# SPDX-FileCopyrightText: 2026 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

# Generated from the packaged template on every upgrade and setup:
# local edits to this file are overwritten.
# To change the values, set them in /etc/zextras/service-discover/carbonio-videoserver.env
# (KEY=value lines; keys and defaults are printed at the end of carbonio-videoserver setup),
# then run carbonio-videoserver setup.

services {
  check {
    tcp      = "127.0.0.1:8088"
    timeout  = "{{ or (env "CHECK_TIMEOUT") "1s" }}"
    interval = "{{ or (env "CHECK_INTERVAL") "5s" }}"
  }

  connect {
    sidecar_service {
      proxy {
        local_service_address = "127.0.0.1"
        upstreams             = [
          {
            destination_name   = "carbonio-message-broker"
            local_bind_address = "127.0.0.1"
            local_bind_port    = 20001
          }
        ]
      }
    }
  }

  name = "carbonio-videoserver"
  port = 8088
}
