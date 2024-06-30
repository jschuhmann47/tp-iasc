defmodule SupervisorBloques do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    nodo_datos_cantidad = Application.get_env(:tp_iasc, :nodo_datos_cantidad)

    children =
      for i <- 0..nodo_datos_cantidad do
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
