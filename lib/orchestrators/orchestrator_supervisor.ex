defmodule OrchestratorSupervisor do
  alias TpIasc.Helpers
  use Horde.DynamicSupervisor
  require Logger

  def start_link(init_arg) do
    Logger.info("Starting OrchestratorSupervisor")
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(init_arg) do
    Horde.DynamicSupervisor.init([strategy: :one_for_one, members: :auto] ++ init_arg)
  end

  def start_orchestrator(name) do
    dictionary_count = Application.get_env(:tp_iasc, :dictionary_count, 10)

    child_spec = %{
      id: name,
      start: {Orchestrators.Orchestrator, :start_link, [dictionary_count, name]},
      restart: :transient
    }

    Logger.info("Attempting to start orchestrator #{name} with spec #{inspect(child_spec)}")

    case Horde.DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:ok, pid} ->
        Logger.info("Started orchestrator #{name} with pid #{inspect(pid)}")

        if check_if_no_master() do
          # Sets itself as master if no masters are available
          GenServer.cast(pid, {:set_master, name})
        else
          GenServer.cast(pid, {:set_master, Helpers.get_master()})
        end

        # This registration is not necessary since it's registered when start_child runs
        # case Horde.Registry.register(TpIasc.Registry, name, pid) do
        #   {:ok, registered_pid} ->
        #     Logger.info("Registered orchestrator #{name} with pid #{inspect(registered_pid)}")

        #     if pid != registered_pid do
        #       Logger.warning(
        #         "Mismatch in PIDs: started pid #{inspect(pid)}, registered pid #{inspect(registered_pid)}"
        #       )
        #     end

        #     {:ok, registered_pid}

        #   {:error, {:already_registered, registered_pid}} ->
        #     Logger.info(
        #       "Orchestrator #{name} is already registered with pid #{inspect(registered_pid)}"
        #     )

        #     if pid != registered_pid do
        #       Logger.warning(
        #         "Mismatch in PIDs: started pid #{inspect(pid)}, already registered pid #{inspect(registered_pid)}"
        #       )
        #     end

        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info("Orchestrator #{name} is already started with pid #{inspect(pid)}")
        {:ok, pid}

      {:error, reason} ->
        Logger.error("Failed to start orchestrator #{name}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def check_if_no_master do
    nil == Helpers.get_master()
  end
end
