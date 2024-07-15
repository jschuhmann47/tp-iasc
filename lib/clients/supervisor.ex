defmodule Clients.Supervisor do
  use Supervisor
  require Logger

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    # + Enum.random(1..100) # Idea: if only one client is used across all nodes, use the same port and if it's in use don't do anything
    port = 8080

    children = [
      {Plug.Cowboy, scheme: :http, plug: Clients.ClientHandler, options: [port: port]},
      %{
        id: Clients.GetMaster,
        start: {Clients.GetMaster, :start_link, []},
        restart: :transient
      }
    ]

    Logger.info("Listening on port #{port}")
    # rest for one so that if client dies, getMaster dies too
    Supervisor.init(children, strategy: :rest_for_one)
  end
end
