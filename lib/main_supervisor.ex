# Supervisor de supervisores
defmodule MainSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    dispatch = :cowboy_router.compile([
      {:_, [{"/", Cliente.ClienteHandler, []}]}
    ])
    {:ok, _} = :cowboy.start_clear(:http,
                          [port: 8080],
                          %{env: [dispatch: dispatch]})
    children = [
      %{
        id: SupervisorBloques,
        start: {SupervisorBloques, :start_link, [SupervisorBloques]},
        restart: :transient
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
        id: Cliente.ClienteSupervisor,
        start: {Cliente.ClienteSupervisor, :start_link, [Cliente.ClienteSupervisor]},
        restart: :transient
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
