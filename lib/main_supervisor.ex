defmodule MainSupervisor do
  require Logger
  use Horde.DynamicSupervisor

  @dictionary_registry TpIasc.Registry

  def start_link(init_arg) do
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(init_arg) do
    Horde.DynamicSupervisor.init([strategy: :one_for_one, members: :auto] ++ init_arg)
  end

  def start_child(child_spec) do
    Horde.DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def init_child_processes do
    start_child(%{
      id: @dictionary_registry,
      start:
        {Horde.Registry, :start_link, [keys: :unique, name: @dictionary_registry, members: :auto]},
      restart: :permanent
    })

    start_child(%{
      id: BlockSupervisor,
      start: {BlockSupervisor, :start_link, [[]]},
      restart: :transient
    })

    start_child(%{
      id: Block.DictionarySupervisor,
      start: {Block.DictionarySupervisor, :start_link, [[]]},
      restart: :transient
    })

    start_child(%{
      id: Clients.Supervisor,
      start: {Clients.Supervisor, :start_link, [[]]},
      restart: :transient
    })
  end
end
