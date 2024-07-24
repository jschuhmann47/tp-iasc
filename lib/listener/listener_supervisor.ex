defmodule BlockSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    dictionary_count = Application.get_env(:tp_iasc, :dictionary_count)

    children =
      [
        {Registry, keys: :unique, name: Block.ListenerRegistry}
      ] ++
        for i <- 0..(dictionary_count - 1) do
          Supervisor.child_spec(
            %{
              id: {:block_listener, i},
              start: {Block.Listener, :start_link, [i]},
              restart: :transient
            },
            id: {:block_listener, i}
          )
        end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
