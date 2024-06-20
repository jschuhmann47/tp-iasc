defmodule Cliente.ClienteSupervisor do
  use Supervisor

  def start_link(_etc) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_arg) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Cliente.ClienteHandler, port: 8080}
    ]

    opts = [strategy: :one_for_one, name: Cliente.ClienteSupervisor]
    Supervisor.init(children, opts)
  end
end
