defmodule Block.Listener do
  use GenServer
  require Logger

  @listener_registry Block.ListenerRegistry

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
    do: {:via, Registry, {@listener_registry, {:block_listener, node_id}}}

  def handle_call({:get, key}, _from, node_id) do
    value =
      case get_first_replica_avaliable(node_id) do
        nil ->
          Logger.info("No replica found in node #{node_id}")
          nil

        agent_name ->
          Logger.debug("Getting key #{inspect(key)} from dictionary #{inspect(agent_name)}")
          Block.Dictionary.value(agent_name, key)
      end

    {:reply, value, node_id}
  end

  def handle_call({:get_lesser, value}, _from, node_id) do
    value =
      case get_first_replica_avaliable(node_id) do
        nil ->
          Logger.info("No replica found in node #{node_id}")
          nil

        agent_name ->
          Logger.debug(
            "Getting lessers from value #{inspect(value)} from dictionary #{inspect(agent_name)}"
          )

          Block.Dictionary.lesser(agent_name, value)
      end

    {:reply, value, node_id}
  end

  def handle_call({:get_greater, value}, _from, node_id) do
    value =
      case get_first_replica_avaliable(node_id) do
        nil ->
          Logger.info("No replica found in node #{node_id}")
          nil

        agent_name ->
          Logger.debug(
            "Getting greaters from value #{inspect(value)} from dictionary #{inspect(agent_name)}"
          )

          Block.Dictionary.greater(agent_name, value)
      end

    {:reply, value, node_id}
  end

  def handle_call({:keys_distribution}, _from, node_id) do
    # TODO: this is using replica 1. Should fix but not necessary
    keys = Block.Dictionary.keys(get_name_from_node_and_replica(node_id, 1))
    {:reply, keys, node_id}
  end

  def handle_cast({:put, key, value}, node_id) do
    send_to_all_replicas(node_id, key, value)
    {:noreply, node_id}
  end

  defp send_to_all_replicas(node_id, key, value) do
    max = Application.get_env(:tp_iasc, :replication_factor, 3)

    1..max
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

  def get_names_for_all_replicas(node_id) do
    max = Application.get_env(:tp_iasc, :replication_factor, 3)
    1..max |> Enum.map(fn n -> get_name_from_node_and_replica(node_id, n) end)
  end

  def get_first_replica_avaliable(node_id) do
    get_names_for_all_replicas(node_id)
    |> Enum.find(nil, fn agent ->
      Registry.lookup(@listener_registry, agent)
    end)
  end
end
