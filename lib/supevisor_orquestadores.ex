defmodule OrchestratorSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    dictionary_count = Application.get_env(:tp_iasc, :dictionary_count)

    children = [
      %{
        id: Orchestrator1,
        start: {Orchestrators.Orchestrator, :start_link, [[], dictionary_count, Orchestrator1]},
        restart: :transient
      },
      %{
        id: Orchestrator2,
        start: {Orchestrators.Orchestrator, :start_link, [[], dictionary_count, Orchestrator2]},
        restart: :transient
      },
      %{
        id: Orchestrator3,
        start: {Orchestrators.Orchestrator, :start_link, [[], dictionary_count, Orchestrator3]},
        restart: :transient
      },
      %{
        id: Orchestrator4,
        start: {Orchestrators.Orchestrator, :start_link, [[], dictionary_count, Orchestrator4]},
        restart: :transient
      },
      %{
        id: Orchestrator5,
        start: {Orchestrators.Orchestrator, :start_link, [[], dictionary_count, Orchestrator5]},
        restart: :transient
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
