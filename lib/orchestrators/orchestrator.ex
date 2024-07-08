defmodule Orchestrators.Orchestrator do
  use GenServer
  require Logger

  @dictionary_registry TpIasc.Registry # think that this should go elsewhere

  def start_link(is_master, dictionary_count, name) do
    GenServer.start_link(__MODULE__, {is_master, dictionary_count}, name: name)
  end

  def init({is_master, dictionary_count}) do
    {:ok, %{is_master: is_master, dictionary_count: dictionary_count}}
  end

  def handle_call({:ping}, _from, state) do
    {:reply, :pong, state}
  end

  def handle_call(:is_master, _from, state) do
    %{is_master: is_master} = state
    {:reply, is_master, state}
  end

  def handle_call({:get, key}, _from, state) do
    %{dictionary_count: dictionary_count} = state
    node_number = node_number_from_key(key, dictionary_count)

    case get_node_from_number(node_number) do
      [{pid, _value}] ->
        value = GenServer.call(pid, {:get, key})
        {:reply, value, state}

      [] ->
        {:reply, :not_found, state}
    end
  end

  def handle_call(:keys_distribution, _from, state) do
    %{dictionary_count: dictionary_count} = state

    keys_distribution =
      Enum.map(0..(dictionary_count - 1), fn node_number ->
        keys = Block.Listener.keys(node_number)
        {node_number, keys}
      end)

    {:reply, keys_distribution, state}
  end

  def handle_cast({:put, key, value}, state) do
    %{dictionary_count: dictionary_count} = state
    node_number = node_number_from_key(key, dictionary_count)

    case get_node_from_number(node_number) do
      [{pid, _value}] ->
        GenServer.cast(pid, {:put, key, value})
        {:noreply, state}

      [] ->
        Logger.error("No process found for node_number #{node_number}")
        {:noreply, state}
    end
  end

  def node_number_from_key(key, node_quantity) do
    :erlang.phash2(key, node_quantity)
  end

  def get_node_from_number(node_number) do
    # exists = case Horde.Registry.lookup(@dictionary_registry, node_number) do
    #   [] -> false
    #   _ -> true
    # end
    # if exists do
    #   Horde.Registry.lookup(@dictionary_registry, node_number) |> List.first |> elem(0)
    # else
    #   Logger.info("Non existing node_number #{node_number}")
    #   nil
    # end
    Horde.Registry.lookup(@dictionary_registry, node_number)
  end
end
