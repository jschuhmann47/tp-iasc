defmodule Clients.GetMaster do
  use Agent
  require Logger

  @orchestrators [Orchestrator1, Orchestrator2, Orchestrator3, Orchestrator4, Orchestrator5]

  def start_link() do
    Logger.info("GetMaster started")
    # TODO, add name and store it in registry
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  # basically, if it's the first time asking for master, a reference is stored. if not it gets it.
  def get_master() do
    {_, %{master: orchestrator_stored}} =
      Agent.get(
        __MODULE__,
        &Map.get_and_update(&1, :master, fn x ->
          case x do
            nil ->
              {:master,
               Enum.find(@orchestrators, fn orchestrator ->
                 GenServer.call(orchestrator, :is_master)
               end)}

            x ->
              x
          end
        end)
      )

    orchestrator_stored
  end
end
