defmodule MainSupervisor do
  require Logger
  use Horde.DynamicSupervisor

  @dictionary_registry TpIasc.Registry

  def start_link(init_arg) do
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(init_arg) do
    members = Enum.map(Node.list([:this, :visible]), &{__MODULE__, &1})
    Horde.DynamicSupervisor.init([strategy: :one_for_one, members: members] ++ init_arg)
  end

  def start_child(child_spec) do
    Horde.DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def init_child_processes do
    start_child(%{
      id: @dictionary_registry,
      start: {Horde.Registry, :start_link, [keys: :unique, name: @dictionary_registry]},
      restart: :permanent
    })

    start_child(%{
      id: BlockSupervisor,
      start: {BlockSupervisor, :start_link, [[]]},
      restart: :transient
    })

    start_child(%{
      id: OrchestratorSupervisor,
      start: {OrchestratorSupervisor, :start_link, [[]]},
      restart: :transient
    })

    start_child(%{
      id: Block.BSupervisor,
      start: {Block.BSupervisor, :start_link, [[]]},
      restart: :transient
    })
    port = 8080 # + Enum.random(1..100)
    Logger.info("Port: #{port}")
    start_child(
      {Plug.Cowboy, scheme: :http, plug: Clients.ClientHandler, options: [port: port]}
    )
  end
end
