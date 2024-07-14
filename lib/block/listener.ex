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

  defp via_tuple(node_id), do: {:via, Horde.Registry, {@block_listener_registry, node_id}}

  def handle_call({:get, key}, _from, node_id) do
    value = Block.Dictionary.value({:global, {:block_dictionary, node_id}}, key)
    {:reply, value, node_id}
  end

  def handle_call({:get_lesser, key}, _from, node_id) do
    value = Block.Dictionary.lesser({:global, {:block_dictionary, node_id}}, key)
    {:reply, value, node_id}
  end

  def handle_call({:get_greater, key}, _from, node_id) do
    value = Block.Dictionary.greater({:global, {:block_dictionary, node_id}}, key)
    {:reply, value, node_id}
  end

  def handle_call(:keys, _from, node_id) do
    keys = Block.Dictionary.keys({:global, {:block_dictionary, node_id}})
    {:reply, keys, node_id}
  end

  def handle_cast({:put, key, value}, node_id) do
    Block.Dictionary.update({:global, {:block_dictionary, node_id}}, key, value)
    {:noreply, node_id}
  end
end
