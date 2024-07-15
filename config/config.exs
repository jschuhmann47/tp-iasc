import Config

config :tp_iasc,
  dictionary_count: 10,
  replication_factor: 3,
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
