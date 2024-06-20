defmodule Clientes.ClienteSupervisor do
  use Supervisor

  @cantidad_clientes 3

  def start_link(_etc) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_arg) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Clientes.ClienteHandler, port: 8080}
    ]

    opts = [strategy: :one_for_one, name: Clientes.ClienteSupervisor]
    Supervisor.init(children, opts)
  end
end
