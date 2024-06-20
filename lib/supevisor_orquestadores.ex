defmodule SupervisorOrquestadores do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    nodo_datos_cantidad = 10  # TODO: obtener de la configuración?

    children = [
      %{id: Orquestador1, start: {Orquestadores.Orquestador, :start_link, [[], nodo_datos_cantidad, Orquestador1]}, restart: :transient},
      %{id: Orquestador2, start: {Orquestadores.Orquestador, :start_link, [[], nodo_datos_cantidad, Orquestador2]}, restart: :transient},
      %{id: Orquestador3, start: {Orquestadores.Orquestador, :start_link, [[], nodo_datos_cantidad, Orquestador3]}, restart: :transient},
      %{id: Orquestador4, start: {Orquestadores.Orquestador, :start_link, [[], nodo_datos_cantidad, Orquestador4]}, restart: :transient},
      %{id: Orquestador5, start: {Orquestadores.Orquestador, :start_link, [[], nodo_datos_cantidad, Orquestador5]}, restart: :transient},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
