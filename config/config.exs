import Config

config :tp_iasc,
  dictionary_count: 10, # D
  replication_factor: 3, # R
  key_length: 3, # Key length
  value_length: 10, # Value length
  max_node_capacity: 50, # N
  node_quantity: 3, # M
  log_level: :debug

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
