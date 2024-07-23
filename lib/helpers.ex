defmodule TpIasc.Helpers do
  require Logger

  def list_registry_members do
    Horde.Cluster.members(TpIasc.Registry)
  end

  def list_orchestrators do
    Horde.Registry.select(TpIasc.Registry, [{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.filter(&contains_orchestrator?/1)
  end

  # TpIasc.Helpers.get_master()
  def get_master do
    Enum.find(list_orchestrators(), fn orchestrator ->
      GenServer.call(Orchestrators.Orchestrator.via_tuple(orchestrator), :is_master)
    end)
  end

  # TODO this can be improved... if we have time...
  defp contains_orchestrator?(value) do
    case value do
      _ when is_integer(value) -> false
      {:block_dictionary, _, _} -> false
      {:block_listener, _} -> false
      _ -> String.contains?(to_string(value), "Orchestrator")
    end
  end

  def see_all_registered do
    Horde.Registry.select(TpIasc.Registry, [
      {{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}
    ])
    |> Enum.sort()
  end

  def list_dictionaries do
    Horde.Registry.select(TpIasc.Registry, [
      {{{:block_dictionary, :"$1", :"$2"}, :_, :_}, [], [{{:block_dictionary, :"$1", :"$2"}}]}
    ])
  end

  def list_local_listeners do
    Registry.select(Block.ListenerRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  def log_orchestrator_pids do
    for orchestrator <- list_orchestrators() do
      orchestrator_pid =
        case Horde.Registry.lookup(TpIasc.Registry, orchestrator) do
          [{pid, _}] -> pid
          [] -> :undefined
        end

      Logger.info(
        "Orchestrator #{inspect(orchestrator)} has pid #{inspect(orchestrator_pid)} on node #{node_of_pid(orchestrator_pid)}"
      )
    end
  end

  def log_dictionary_pids do
    for dictionary <- list_dictionaries() do
      dictionary_pid =
        case Horde.Registry.lookup(TpIasc.Registry, dictionary) do
          [{pid, _}] -> pid
          [] -> :undefined
        end

      Logger.info(
        "Dictionary #{inspect(dictionary)} has pid #{inspect(dictionary_pid)} on node #{node_of_pid(dictionary_pid)}"
      )
    end
  end

  def log_local_listeners do
    for listener <- list_local_listeners() do
      listener_pid =
        Registry.lookup(Block.ListenerRegistry, listener)
        |> Enum.map(fn {pid, _} -> pid end)
        |> List.first()

      Logger.info(
        "Local listener #{inspect(listener)} has pid #{inspect(listener_pid)} on node #{node_of_pid(listener_pid)}"
      )
    end
  end

  def log_registry_members do
    for member <- list_registry_members() do
      Logger.info("Registry member: #{inspect(member)}")
    end
  end

  # TpIasc.Helpers.log_all()
  def log_all do
    log_orchestrator_pids()
    log_dictionary_pids()
    log_local_listeners()
  end

  defp node_of_pid(pid) when is_pid(pid), do: :erlang.node(pid)
  defp node_of_pid(_), do: :undefined
end
