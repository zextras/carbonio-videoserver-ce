services {
  check {
    tcp      = "127.78.0.16:10000"
    timeout  = "1s"
    interval = "5s"
  }
  connect {
    sidecar_service {
      proxy {
        local_service_address = "127.78.0.16"
        upstreams             = [
          {
            destination_name   = "carbonio-videoserver-recorder"
            local_bind_address = "127.78.0.16"
            local_bind_port    = 20000
          }
        ]
      }
    }
  }

  name = "carbonio-videoserver"
  port = 10000
}