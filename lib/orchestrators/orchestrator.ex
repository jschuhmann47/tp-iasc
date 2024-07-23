defmodule Orchestrators.Orchestrator do
  alias TpIasc.Helpers
  use GenServer
  require Logger

  # think that this should go elsewhere
  @dictionary_registry TpIasc.Registry

  def start_link(dictionary_count, name) do
    GenServer.start_link(__MODULE__, {dictionary_count, name}, name: via_tuple(name))
  end

  def via_tuple(name), do: {:via, Horde.Registry, {@dictionary_registry, name}}

  def init({dictionary_count, name}) do
    # this is so it's unlikely for two orchestrators to initiate selection at the same time
    :net_kernel.monitor_nodes(true)
    interval = 4000 + :rand.uniform(2000)
    :timer.send_interval(interval, :ping_master)

    {:ok,
     %{
       dictionary_count: dictionary_count,
       my_name: name,
       master_name: nil
     }}
  end

  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end

  def handle_call(:is_master, _from, state) do
    {:reply, am_i_master?(state), state}
  end

  def handle_call({:get, key}, _from, state) do
    %{dictionary_count: dictionary_count} = state
    node_number = node_number_from_key(key, dictionary_count)
    {:reply, cast_or_call_action_to_node(:call, node_number, {:get, key}), state}
  end

  def handle_call({:get_lesser, value}, _from, state) do
    call_action_to_all_nodes(state, :get_lesser, value)
  end

  def handle_call({:get_greater, value}, _from, state) do
    call_action_to_all_nodes(state, :get_greater, value)
  end

  def handle_call(:keys_distribution, _from, state) do
    %{dictionary_count: dictionary_count} = state

    keys_distribution =
      0..(dictionary_count - 1)
      |> Enum.map(fn node_number ->
        keys = cast_or_call_action_to_node(:call, node_number, :keys_distribution)
        {node_number, keys}
      end)

    {:reply, keys_distribution, state}
  end

  def call_action_to_all_nodes(state, action, value) do
    %{dictionary_count: dictionary_count} = state

    res =
      0..(dictionary_count - 1)
      |> Enum.map(fn x -> cast_or_call_action_to_node(:call, x, {action, value}) end)
      |> List.flatten()
      |> Enum.sort()

    {:reply, res, state}
  end

  def handle_cast({:set_master, master_name}, state) do
    %{my_name: my_name, dictionary_count: dictionary_count} = state

    new_state = %{
      my_name: my_name,
      dictionary_count: dictionary_count,
      master_name: master_name
    }

    {:noreply, new_state}
  end

  def handle_cast({:put, key, value}, state) do
    %{dictionary_count: dictionary_count} = state
    node_number = node_number_from_key(key, dictionary_count)

    cast_or_call_action_to_node(:cast, node_number, {:put, key, value})
    {:noreply, state}
  end

  def handle_cast({:delete, key}, state) do
    %{dictionary_count: dictionary_count} = state
    node_number = node_number_from_key(key, dictionary_count)
    cast_or_call_action_to_node(:cast, node_number, {:delete, key})
    {:noreply, state}
  end

  defp cast_or_call_action_to_node(calltype, n, action) do
    case get_listener_from_number(n) do
      [{pid, _value}] ->
        cast_or_call(calltype, pid, action)

      [] ->
        Logger.error("Cannot #{calltype} action: No process found for node_number #{n}")
        nil
    end
  end

  defp cast_or_call(:cast, pid, action), do: GenServer.cast(pid, action)
  defp cast_or_call(:call, pid, action), do: GenServer.call(pid, action)

  def node_number_from_key(key, node_quantity) do
    :erlang.phash2(key, node_quantity)
  end

  def get_listener_from_number(node_number) do
    Registry.lookup(Block.ListenerRegistry, {:block_listener, node_number})
  end

  defp select_master(state) do
    %{master_name: master_name, my_name: my_name, dictionary_count: dictionary_count} = state

    everyone_but_current_master =
      Helpers.list_orchestrators() |> Enum.reject(fn o -> o == master_name end)

    one_non_master = everyone_but_current_master |> Enum.random()

    Helpers.list_orchestrators()
    |> Enum.map(fn o ->
      GenServer.cast(Orchestrators.Orchestrator.via_tuple(o), {:set_master, one_non_master})
    end)

    new_state = %{
      my_name: my_name,
      dictionary_count: dictionary_count,
      master_name: one_non_master
    }

    {:noreply, new_state}
  end

  defp am_i_master?(state) do
    %{master_name: master_name, my_name: my_name} = state
    master_name == my_name
  end

  def handle_info(:ping_master, state) do
    %{master_name: master_name} = state

    if master_name == nil do
      select_master(state)
    end

    if !am_i_master?(state) do
      if master_name == nil do
        select_master(state)
      else
        try do
          res = GenServer.call(via_tuple(master_name), :is_master)

          case res do
            true -> {:noreply, state}
            false -> select_master(state)
          end
        catch
          _ -> select_master(state)
        end
      end
    else
      {:noreply, state}
    end
  end

  def handle_info({:nodeup, node}, state) do
    Logger.info("#{__MODULE__} received nodeup event: node #{inspect(node)}")
    if are_all_nodes_up?() && am_i_master?(state) do
      Logger.info("All nodes are up")

      # sleep for a bit to allow all nodes to be fully up
      :timer.sleep(2000)

      Block.DictionarySupervisor.start_dictionaries()
    else
      Logger.info("#{__MODULE__} Not all nodes are up yet or this node is not the master orchestrator")
    end
    {:noreply, state}
  end

  def handle_info({:nodedown, node}, state) do

    Logger.info("#{__MODULE__} received nodedown event: node #{inspect(node)}")
    {:noreply, state}
  end

  def are_all_nodes_up?() do
    node_count = length(Node.list()) + 1
    node_count == Application.get_env(:tp_iasc, :node_quantity)
  end


end
