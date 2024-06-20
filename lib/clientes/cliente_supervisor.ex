defmodule Clientes.ClienteSupervisor do
  use Supervisor

  @cantidad_clientes 3

  def start_link(_etc) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_arg) do
    children =
      #for i <- 1..@cantidad_clientes do
        [{Plug.Cowboy, scheme: :http, plug: Clientes.ClienteHandler, port: 8080}]
      #end
      #  bad child specification, more than one child specification has the id: {:ranch_listener_sup, Clientes.ClienteHandler.HTTP}.
      # If using maps as child specifications, make sure the :id keys are unique.
      # If using a module or {module, arg} as child, use Supervisor.child_spec/2 to change the :id,

    opts = [strategy: :one_for_one, name: Clientes.ClienteSupervisor]
    Supervisor.init(children, opts)
  end
end
