import Config

config :tp_iasc,
  # D
  dictionary_count: 10,
  # R
  replication_factor: 2,
  # Key length
  key_length: 10,
  # Value length
  value_length: 10,
  # N
  max_node_capacity: 50,
  # M
  node_quantity: 3,
  log_level: :debug,
  port: 8080

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
