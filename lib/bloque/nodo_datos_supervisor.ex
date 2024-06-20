defmodule Bloque.NodoDatosSupervisor do
  use Supervisor

  @nodo_datos_cantidad 10 # Cantidad de nodos de datos, por ahora igual a la cantidad de servidores

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children =
      for i <- 0..@nodo_datos_cantidad do
        %{
          id: {:bloque_nodo_datos_agent, i},
          start: {Bloque.NodoDatos, :start_link, [{:global, {:nodo_datos, i}}]},
          restart: :transient
        }
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
