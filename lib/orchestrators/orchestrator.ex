defmodule Orchestrators.Orchestrator do
  use GenServer
  require Logger

  @dictionary_registry TpIasc.Registry # think that this should go elsewhere
  @is_master false

  def start_link(initial_state, dictionary_count, name) do
    GenServer.start_link(__MODULE__, {initial_state, dictionary_count}, name: name)
  end

  # TODO add is master here
  def init({state, dictionary_count}) do
    {:ok, %{state: state, dictionary_count: dictionary_count}}
  end

  def handle_call({:get, key}, _from, state_data) do
    %{dictionary_count: dictionary_count} = state_data
    node_number = node_number_from_key(key, dictionary_count)

    case get_node_from_number(node_number) do
      [{pid, _value}] ->
        value = GenServer.call(pid, {:get, key})
        {:reply, value, state_data}

      nil ->
        {:reply, :not_found, state_data}
    end
  end

  def handle_call(:keys_distribution, _from, state_data) do
    %{dictionary_count: dictionary_count} = state_data

    keys_distribution =
      Enum.map(0..(dictionary_count - 1), fn node_number ->
        keys = Block.Listener.keys(node_number)
        {node_number, keys}
      end)

    {:reply, keys_distribution, state_data}
  end

  def handle_cast({:put, key, value}, state_data) do
    %{dictionary_count: dictionary_count} = state_data
    node_number = node_number_from_key(key, dictionary_count)

    case get_node_from_number(node_number) do
      [{pid, _value}] ->
        GenServer.cast(pid, {:put, key, value})
        {:noreply, state_data}

      nil ->
        Logger.error("No process found for node_number #{node_number}")
        {:noreply, state_data}
    end
  end

  def node_number_from_key(key, node_quantity) do
    :erlang.phash2(key, node_quantity)
  end

  def get_node_from_number(node_number) do
    exists = case Horde.Registry.lookup(@dictionary_registry, node_number) do
      [] -> false
      _ -> true
    end
    if exists do
      Horde.Registry.lookup(@dictionary_registry, node_number) |> List.first |> elem(0)
    else
      Logger.info("Non existing node_number #{node_number}")
      nil
    end
  end
end
