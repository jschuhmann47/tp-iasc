defmodule Block.DictionarySupervisor do
  use Horde.DynamicSupervisor
  require Logger

  def start_link(init_arg) do
    Logger.debug("#{__MODULE__} starting with init arg #{inspect(init_arg)}")
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(child_spec) do
    Logger.debug("#{__MODULE__} starting child with spec #{inspect(child_spec)}")
    Horde.DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def init(_init_arg) do
    Horde.DynamicSupervisor.init(
      strategy: :one_for_one,
      distribution_strategy: Horde.UniformDistribution,
      process_redistribution: :active,
      members: :auto
    )
  end

  def start_dictionaries do
    Logger.debug("#{__MODULE__} starting dictionaries")
    node_quantity = Application.get_env(:tp_iasc, :node_quantity)
    actual_node_count = length(Node.list()) + 1

    if actual_node_count == node_quantity do
      dictionary_count = Application.get_env(:tp_iasc, :dictionary_count)
      replication_factor = Application.get_env(:tp_iasc, :replication_factor)

      children =
        for i <- 0..(dictionary_count - 1) do
          for j <- 0..(replication_factor - 1) do
            node_index = rem(i + j, node_quantity)
            node_name = Enum.at(Node.list(), node_index) || Node.self()

            Logger.debug(
              "#{__MODULE__} starting dictionary #{i} replica #{j} on node #{node_name}"
            )

            %{
              id: {:block_dictionary, i, j},
              start: {Block.Dictionary, :start_link, [{:block_dictionary, i, j}]},
              restart: :transient,
              node: node_name
            }
          end
        end

      List.flatten(children)
      |> Enum.each(&start_distributed_child/1)
    else
      Logger.warning(
        "Node count is #{actual_node_count}, expected #{node_quantity}. Dictionaries will not be started."
      )
    end
  end

  defp start_distributed_child(child_spec) do
    node = Map.get(child_spec, :node, Node.self())

    Task.start(fn ->
      :rpc.call(node, Horde.DynamicSupervisor, :start_child, [
        TpIasc.DistributedSupervisor,
        child_spec
      ])
    end)
  end

  def handle_info(msg, state) do
    Logger.error("Unhandled message: #{inspect(msg)}")
    {:noreply, state}
  end
end
