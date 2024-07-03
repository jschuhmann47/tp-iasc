defmodule TpIasc.DistributedSupervisor do
  use Horde.DynamicSupervisor

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
end
