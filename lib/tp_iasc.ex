defmodule TpIasc do
  require Logger
  use Application

  def start(_type, _args) do
    configure_logging()
    name_application()

    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      {Cluster.Supervisor, [topologies, [name: TpIasc.ClusterSupervisor]]},
      {Horde.Registry, [keys: :unique, name: TpIasc.Registry]},
      {TpIasc.DistributedSupervisor,
       [
         strategy: :one_for_one,
         distribution_strategy: Horde.UniformQuorumDistribution,
         process_redistribution: :active
       ]}
    ]

    opts = [strategy: :one_for_one, name: TpIasc.Supervisor]
    Supervisor.start_link(children, opts)

    start_supervised_processes()

    assign_random_master()

    {:ok, self()}
  end

  defp start_supervised_processes do
    # Esperar un momento para asegurarse de que todos los nodos se hayan unido al clúster
    :timer.sleep(2000)

    # Iniciar MainSupervisor y sus procesos hijos
    MainSupervisor.start_link([])
    MainSupervisor.init_child_processes()
  end

  defp assign_random_master do
    :timer.sleep(1000)
    orchestrators = [Orchestrator1, Orchestrator2, Orchestrator3, Orchestrator4, Orchestrator5]
    random_orchestrator = Enum.random orchestrators
    orchestrators |> Enum.each(fn o -> GenServer.cast(o, {:set_master, random_orchestrator}) end)
  end

  def name_application() do
    Process.register(self(), TpIasc)
  end

  defp configure_logging() do
    log_level = Application.get_env(:tp_iasc, :log_level, :info)
    Logger.configure(level: log_level)
    Logger.info("Starting TP with log level #{log_level}")
  end
end
