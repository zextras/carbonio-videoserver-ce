services {
  connect {
    sidecar_service {
      proxy {
        local_service_address = "127.0.0.1"
        upstreams             = [
          {
            destination_name   = "carbonio-videoserver-recorder"
            local_bind_address = "127.0.0.1"
            local_bind_port    = 20000
          },
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