# Supervisor de supervisores
defmodule MainSupervisor do
  use Supervisor

  @nodo_datos_registry_name :nodo_datos_registry

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do

    children = [
      {Registry, [keys: :unique, name: @nodo_datos_registry_name]},
      %{
        id: SupervisorBloques,
        start: {SupervisorBloques, :start_link, [SupervisorBloques]},
      },
      %{
        id: SupervisorOrquestadores,
        start: {SupervisorOrquestadores, :start_link, [SupervisorOrquestadores]},
        restart: :transient
      },
      %{
        id: Bloque.NodoDatosSupervisor,
        start: {Bloque.NodoDatosSupervisor, :start_link, [Bloque.NodoDatosSupervisor]},
        restart: :transient
      },
      %{
        id: Clientes.ClienteSupervisor,
        start: {Clientes.ClienteSupervisor, :start_link, [Clientes.ClienteSupervisor]},
        restart: :transient
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
