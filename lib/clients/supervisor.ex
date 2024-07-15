defmodule Clients.Supervisor do
  use Supervisor
  require Logger

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    port = 8080 # + Enum.random(1..100) # Idea: if only one client is used across all nodes, use the same port and if it's in use don't do anything

    children = [
      {Plug.Cowboy, scheme: :http, plug: Clients.ClientHandler, options: [port: port]},
      %{
        id: Clients.GetMaster,
        start: {Clients.GetMaster, :start_link, []},
        restart: :transient
      }
    ]

    Logger.info("Listening on port #{port}")
    Supervisor.init(children, strategy: :rest_for_one) # rest for one so that if client dies, getMaster dies too
  end
end
