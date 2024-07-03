defmodule MainSupervisor do
  require Logger
  use Horde.DynamicSupervisor

  @nodo_datos_registry_name TpIasc.Registry

  def start_link(init_arg) do
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(init_arg) do
    members = Enum.map(Node.list([:this, :visible]), &{__MODULE__, &1})
    Horde.DynamicSupervisor.init([strategy: :one_for_one, members: members] ++ init_arg)
  end

  def start_child(child_spec) do
    Horde.DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def init_child_processes do
    start_child(%{
      id: @nodo_datos_registry_name,
      start: {Horde.Registry, :start_link, [keys: :unique, name: @nodo_datos_registry_name]},
      restart: :permanent
    })

    start_child(%{
      id: SupervisorBloques,
      start: {SupervisorBloques, :start_link, [[]]},
      restart: :transient
    })

    start_child(%{
      id: SupervisorOrquestadores,
      start: {SupervisorOrquestadores, :start_link, [[]]},
      restart: :transient
    })

    start_child(%{
      id: Bloque.NodoDatosSupervisor,
      start: {Bloque.NodoDatosSupervisor, :start_link, [[]]},
      restart: :transient
    })
    port = 8080 + Enum.random(1..100)
    Logger.info("Port: #{port}")
    start_child(
      {Plug.Cowboy, scheme: :http, plug: Clientes.ClienteHandler, options: [port: port]}
    )
  end
end
