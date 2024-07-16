defmodule TpIasc.Helpers do
  require Logger

  def list_registry_members do
    Horde.Cluster.members(TpIasc.Registry)
  end

  def list_orchestrators do
    Horde.Registry.select(TpIasc.Registry, [{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.filter(fn x -> contains_orchestrator?(x) end)
  end

  # should be only one
  def get_master do
    Enum.find(list_orchestrators(), fn orchestrator ->
      GenServer.call(Orchestrators.Orchestrator.via_tuple(orchestrator), :is_master)
    end)
  end

  defp contains_orchestrator?(value) do
    case value do
      # Skip integers (or other non-string types)
      _ when is_integer(value) ->
        false

      _ ->
        str = to_string(value)
        String.contains?(str, "Orchestrator")
    end
  end

  def log_orchestrator_pids do
    for orchestrator <- list_orchestrators() do
      orchestrator_pid = Horde.Registry.lookup(TpIasc.Registry, orchestrator)
      Logger.info("Orchestrator #{orchestrator} has pid #{inspect(orchestrator_pid)}")
    end
  end

  def log_registry_members do
    for member <- list_registry_members() do
      Logger.info("Registry member: #{inspect(member)}")
    end
  end

  def log_all do
    log_orchestrator_pids()
    log_registry_members()
  end
end

# TpIasc.Helpers.list_orchestrators()
