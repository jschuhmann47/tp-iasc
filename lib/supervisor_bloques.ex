defmodule SupervisorBloques do
  use Supervisor

  @nodo_datos_cantidad 10

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children =
      for i <- 1..@nodo_datos_cantidad do
        Supervisor.child_spec(
          %{
            id: {:bloque_nodo_datos_server, i},
            start: {Bloque.NodoDatosServer, :start_link, [i]},
            restart: :transient
          },
          id: {:bloque_nodo_datos_server, i}
        )
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
