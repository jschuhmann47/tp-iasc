defmodule TpIasc.Helpers do
  require Logger

  def list_registry_members do
    Horde.Cluster.members(TpIasc.Registry)
  end

  def list_orchestrators do
    Horde.Registry.select(TpIasc.Registry, [{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.filter(fn x -> contains_orchestrator?(x) end)
  end
  # Horde.Registry.select(TpIasc.Registry, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}]) |> Enum.sort()

  # should be only one
  def get_master do
    Enum.find(list_orchestrators(), fn orchestrator ->
      GenServer.call(Orchestrators.Orchestrator.via_tuple(orchestrator), :is_master)
    end)
  end

  defp contains_orchestrator?(value) do
    case value do
      _ when is_integer(value) ->
        false

      {:block_dictionary, _, _} -> false
      {:block_listener, _,} -> false
      _ ->
        str = to_string(value)
        String.contains?(str, "Orchestrator")
    end
  end

  def see_all_registered do
    Horde.Registry.select(TpIasc.Registry, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}]) |> Enum.sort()
  end

  def list_dictionaries do
    Horde.Registry.select(TpIasc.Registry, [{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.filter(fn x -> is_dictionary?(x) end)
  end

  defp is_dictionary?(value) do
    case value do
      {:block_dictionary, _, _} -> true
      _ -> false
    end
  end

  def log_orchestrator_pids do
    for orchestrator <- list_orchestrators() do
      orchestrator_pid =
        case Horde.Registry.lookup(TpIasc.Registry, orchestrator) do
          [{pid, _}] -> pid
          [] -> :undefined
        end

      Logger.info("Orchestrator #{orchestrator} has pid #{inspect(orchestrator_pid)}")
    end
  end

  def log_dictionary_pids do
    for dictionary_id <- list_dictionaries() do
      dictionary_pid =
        case Horde.Registry.lookup(TpIasc.Registry, {:block_dictionary, dictionary_id}) do
          [{pid, _}] -> pid
          [] -> :undefined
        end

      Logger.info("Dictionary #{dictionary_id} has pid #{inspect(dictionary_pid)}")
    end
  end

  def log_registry_members do
    for member <- list_registry_members() do
      Logger.info("Registry member: #{inspect(member)}")
    end
  end

  # TpIasc.Helpers.log_replication_status()
  def log_replication_status do
    dictionary_count = Application.get_env(:tp_iasc, :dictionary_count)
    replication_factor = Application.get_env(:tp_iasc, :replication_factor)

    for i <- 0..(dictionary_count - 1) do
      replicas =
        Enum.filter(:global.registered_names(), fn name ->
          case name do
            {:block_dictionary, ^i, _} -> true
            _ -> false
          end
        end)

      Logger.info(
        "Dictionary #{i} tiene #{length(replicas)} replicas. Deseadas: #{replication_factor}"
      )

      for replica <- replicas do
        case :global.whereis_name(replica) do
          pid when is_pid(pid) ->
            node = :erlang.node(pid)
            Logger.info("Replica #{inspect(replica)} se encuentra en el nodo #{node}")

          :undefined ->
            Logger.warning("Replica #{inspect(replica)} no está activa")
        end
      end
    end
  end

  def log_all do
    log_orchestrator_pids()
    log_dictionary_pids()
    log_registry_members()
    log_replication_status()
  end

  def list_global_names do
    :global.registered_names()
  end
end

# TpIasc.Helpers.list_orchestrators()
