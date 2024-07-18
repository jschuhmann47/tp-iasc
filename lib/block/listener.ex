defmodule Block.Listener do
  use GenServer
  require Logger

  @block_listener_registry TpIasc.Registry

  def init(node_id) do
    Logger.info("Block listener started with id: #{inspect(node_id)}")
    {:ok, node_id}
  end

  def start_link(node_id) do
    GenServer.start_link(__MODULE__, node_id, name: via_tuple(node_id))
  end

  def child_spec({node_id}) do
    %{
      id: {:block_listener, node_id},
      start: {__MODULE__, :start_link, [node_id]},
      type: :worker,
      restart: :transient
    }
  end

  defp via_tuple(node_id),
    do: {:via, Horde.Registry, {@block_listener_registry, {:block_listener, node_id}}}

  def handle_call({:get, key}, _from, node_id) do
    # TODO: send replica number, now it's hardcoded in 1
    agent_name = get_name_from_node_and_replica(node_id, 1)
    Logger.debug("Getting key #{inspect(key)} from dictionary #{inspect(agent_name)}")
    value = Block.Dictionary.value(agent_name, key)
    {:reply, value, node_id}
  end

  def handle_call({:get_lesser, value}, _from, node_id) do
    res = Block.Dictionary.lesser(get_name_from_node_and_replica(node_id, 1), value)
    {:reply, res, node_id}
  end

  def handle_call({:get_greater, value}, _from, node_id) do
    res = Block.Dictionary.greater(get_name_from_node_and_replica(node_id, 1), value)
    {:reply, res, node_id}
  end

  def handle_call({:keys_distribution}, _from, node_id) do
    keys = Block.Dictionary.keys(get_name_from_node_and_replica(node_id, 1))
    {:reply, keys, node_id}
  end

  def handle_cast({:put, key, value}, node_id) do
    send_to_all_replicas(node_id, key, value)
    {:noreply, node_id}
  end

  defp send_to_all_replicas(node_id, key, value) do
    1..3
    |> Enum.each(fn replica ->
      agent_name = get_name_from_node_and_replica(node_id, replica)

      Logger.debug(
        "Sending key #{inspect(key)} with value #{inspect(value)} to replica #{inspect(agent_name)}"
      )

      Block.Dictionary.update(agent_name, key, value)
    end)
  end

  def get_name_from_node_and_replica(node, replica) do
    Block.Dictionary.via_tuple({:block_dictionary, node, replica})
  end
end
