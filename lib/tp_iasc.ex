defmodule TpIasc do
  require Logger
  use Application

  def start(_type, _args) do
    configure_logging()
    name_application()

    topologies = Application.get_env(:libcluster, :topologies, [])

    children = [
      {Cluster.Supervisor, [topologies, [name: TpIasc.ClusterSupervisor]]},
      {Horde.Registry, [keys: :unique, name: TpIasc.Registry, members: :auto]},
      {TpIasc.DistributedSupervisor,
       [
         strategy: :one_for_one,
         distribution_strategy: Horde.UniformQuorumDistribution,
         process_redistribution: :active,
         members: :auto
       ]},
      {OrchestratorSupervisor, [members: :auto]}
    ]

    opts = [strategy: :one_for_one, name: TpIasc.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, pid} ->
        start_supervised_processes()
        monitor_cluster_membership()
        start_orchestrator()
        {:ok, pid}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp start_supervised_processes do
    # Esperar un momento para asegurarse de que todos los nodos se hayan unido al clúster
    :timer.sleep(2000)

    # Iniciar MainSupervisor y sus procesos hijos
    MainSupervisor.start_link([])
    MainSupervisor.init_child_processes()
  end

  defp start_orchestrator do
    node_name = Node.self() |> to_string()
    orchestrator_name = :"Orchestrator_#{node_name}"

    case Horde.Registry.lookup(TpIasc.Registry, orchestrator_name) do
      [] ->
        case OrchestratorSupervisor.start_orchestrator(orchestrator_name) do
          {:ok, pid} ->
            Logger.info(
              "Orchestrator #{orchestrator_name} started successfully with pid #{inspect(pid)}"
            )

          {:error, reason} ->
            Logger.error("Failed to start Orchestrator #{orchestrator_name}: #{inspect(reason)}")
        end

      [{pid, _}] ->
        Logger.info(
          "Orchestrator #{orchestrator_name} is already registered with pid #{inspect(pid)}"
        )

      _ ->
        Logger.error("Unexpected response when looking up #{orchestrator_name} in Horde.Registry")
    end
  end

  defp monitor_cluster_membership do
    :net_kernel.monitor_nodes(true)
  end

  defp name_application() do
    Process.register(self(), TpIasc)
  end

  defp configure_logging() do
    log_level = Application.get_env(:tp_iasc, :log_level, :info)
    Logger.configure(level: log_level)
    Logger.info("Starting TP with log level #{log_level}")
  end

  def handle_info({:nodeup, _node}, state) do
    Logger.info("Node joined the cluster")
    :timer.sleep(2000)
    Block.DictionarySupervisor.adjust_all_replications()
    {:noreply, state}
  end

  def handle_info({:nodedown, _node}, state) do
    Logger.info("Node left the cluster")
    :timer.sleep(2000)
    Block.DictionarySupervisor.adjust_all_replications()
    {:noreply, state}
  end
end
