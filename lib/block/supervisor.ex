defmodule Block.BSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    dictionary_count = Application.get_env(:tp_iasc, :dictionary_count, 2)
    # TODO: Aqui se deberia definir el tema de la replicacion de los nodos de datos?

    children =
      for i <- 0..dictionary_count do
        %{
          id: {:dictionary, i},
          start: {Block.Dictionary, :start_link, [{:global, {:block_dictionary, i}}]},
          restart: :transient
        }
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
