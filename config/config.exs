import Config

config :tp_iasc,
  nodo_datos_cantidad: 10,
  log_level: :debug,
  http_port: 8051 # Configuración fija del puerto HTTP

  config :libcluster,
  topologies: [
    example: [
      strategy: Cluster.Strategy.Gossip,
      config: [
        port: 45892,
        multicast_addr: "255.255.255.255",
      ]
    ]
  ]
