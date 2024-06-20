defmodule SupervisorOrquestadores do
  use Supervisor

  @cantidad_orquestadores 10

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children =
      for i <- 1..@cantidad_orquestadores do
      %{
        id: {:orquestador, i},
        start: {Orquestadores.Orquestador, :start_link, [{:global, {:instancia_orquestador, i}}]},
        restart: :transient
      }
    end


    Supervisor.init(children, strategy: :one_for_one)
  end
end
