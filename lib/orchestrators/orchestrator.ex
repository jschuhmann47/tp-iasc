defmodule Orchestrators.Orchestrator do
  use GenServer
  require Logger

  # think that this should go elsewhere
  @dictionary_registry TpIasc.Registry
  @orchestrators [Orchestrator1, Orchestrator2, Orchestrator3, Orchestrator4, Orchestrator5]

  def start_link(dictionary_count, name) do
    GenServer.start_link(__MODULE__, {dictionary_count, name}, name: name)
  end

  def init({dictionary_count, name}) do
    # this is so it's unlikely for two orchestrators to initiate selection at the same time
    interval = 4000 + :rand.uniform(2000)
    :timer.send_interval(interval, :ping_master)

    {:ok,
     %{
       is_master: false,
       dictionary_count: dictionary_count,
       my_name: name,
       master_name: nil
     }}
  end

  def handle_call(:ping, _from, state) do
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

  def handle_call({:get_lesser, key}, _from, state) do
    %{dictionary_count: dictionary_count} = state

    res =
      0..dictionary_count
      |> Enum.map(fn x -> aux(x, {:get_lesser, key}) end)
      # TODO: if we know by hash that key 'x' goes to node y, we should search from 0 to y instead of all nodes (same with greater)
      # |> Enum.map(fn {pid, _value} -> GenServer.call(pid, {:get_lesser, key}) end)
      |> List.flatten()

    {:reply, res, state}
  end

  def handle_call({:get_greater, key}, _from, state) do
    %{dictionary_count: dictionary_count} = state

    res =
      0..dictionary_count
      |> Enum.map(fn x -> aux(x, {:get_greater, key}) end)
      # TODO: if we know by hash that key 'x' goes to node y, we should search from 0 to y instead of all nodes (same with greater)
      # |> Enum.map(fn {pid, _value} -> GenServer.call(pid, {:get_lesser, key}) end)
      |> List.flatten()

    {:reply, res, state}
  end

  def aux(n, action) do
    case get_node_from_number(n) do
      [{pid, _value}] ->
        GenServer.call(pid, action)
      [] ->
        ""
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

  def handle_cast({:set_master, master_name}, state) do
    %{my_name: my_name, dictionary_count: dictionary_count} = state

    new_state = %{
      is_master: my_name == master_name,
      my_name: my_name,
      dictionary_count: dictionary_count,
      master_name: master_name
    }

    {:noreply, new_state}
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

  def handle_info(:ping_master, state) do
    %{master_name: master_name, is_master: is_master} = state

    unless is_master or master_name == nil do
      res = GenServer.call(master_name, :is_master)

      case res do
        true -> {:noreply, state}
        # this covers "false" (the ex-master has been restarted, but it isn't master anymore)
        # as well as errors (it hasn't been restarted)
        _ -> select_master(state)
      end
    else
      {:noreply, state}
    end
  end

  defp select_master(state) do
    %{master_name: master_name, my_name: my_name, dictionary_count: dictionary_count} = state
    next_master_name = next_master_name(master_name)
    everyone_but_me = @orchestrators |> Enum.reject(fn o -> o == my_name end)
    everyone_but_me |> Enum.each(fn o -> GenServer.cast(o, {:set_master, next_master_name}) end)

    new_state = %{
      is_master: my_name == master_name,
      my_name: my_name,
      dictionary_count: dictionary_count,
      master_name: master_name
    }

    {:noreply, new_state}
  end

  defp next_master_name(current_master_name) do
    current_id = current_master_name |> Atom.to_string() |> String.last() |> String.to_integer()
    next_id = 1 + rem(current_id, 5)
    "Elixir.Orchestrator#{next_id}" |> String.to_atom()
  end
end
