import Config

config :tp_iasc,
  dictionary_count: 10,
  replication_factor: 3,
  max_node_capacity: 3,
  log_level: :debug,
  # Configuración fija del puerto HTTP
  http_port: 8051

config :libcluster,
  topologies: [
    example: [
      strategy: Cluster.Strategy.Gossip,
      config: [
        port: 45892,
        multicast_addr: "255.255.255.255"
      ]
    ]
  ]
