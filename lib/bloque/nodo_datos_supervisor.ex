defmodule Bloque.NodoDatosSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      %{
        id: Bloque.NodoDatos,
        start: {Bloque.NodoDatos, :start_link, [Bloque.NodoDatos]},
        restart: :transient
      },
      %{
        id: Bloque.NodoDatos2,
        start: {Bloque.NodoDatos, :start_link, [Bloque.NodoDatos2]},
        restart: :transient
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
