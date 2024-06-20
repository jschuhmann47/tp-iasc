defmodule SupervisorOrquestadores do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      %{id: Orquestador1, start: {Orquestadores.Orquestador, :start_link, [[], Orquestador1]}, restart: :transient},
      %{id: Orquestador2, start: {Orquestadores.Orquestador, :start_link, [[], Orquestador2]}, restart: :transient},
      %{id: Orquestador3, start: {Orquestadores.Orquestador, :start_link, [[], Orquestador3]}, restart: :transient},
      %{id: Orquestador4, start: {Orquestadores.Orquestador, :start_link, [[], Orquestador4]}, restart: :transient},
      %{id: Orquestador5, start: {Orquestadores.Orquestador, :start_link, [[], Orquestador5]}, restart: :transient},

    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
