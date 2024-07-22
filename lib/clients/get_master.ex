defmodule Clients.GetMaster do
  alias TpIasc.Helpers
  use Agent
  require Logger

  def start_link() do
    Logger.info("GetMaster started")
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  # basically, if it's the first time asking for master, a reference is stored. if not it gets it.
  def get_master() do
    {_, %{master: orchestrator_stored}} =
      Agent.get(
        __MODULE__,
        &Map.get_and_update(&1, :master, fn current_orchestrator ->
          case current_orchestrator do
            nil ->
              {:master, Helpers.get_master()}

            current_orchestrator ->
              try do
                case GenServer.call(current_orchestrator, :ping) do
                  # is alive so we use the one that's stored
                  :pong -> current_orchestrator
                  # means that it's down so we need to get the new master
                  _ -> {:master, Helpers.get_master()}
                end
              catch
                _ -> {:master, Helpers.get_master()}
              end
          end
        end)
      )

    orchestrator_stored
  end
end
