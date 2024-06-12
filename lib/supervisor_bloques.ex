defmodule SupervisorBloques do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      %{
        id: Bloque.NodoDatosServer,
        start: {Bloque.NodoDatosServer, :start_link, [Bloque.NodoDatosServer]},
        restart: :transient
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
