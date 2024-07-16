defmodule Block.DictionarySupervisor do
  use Horde.DynamicSupervisor
  require Logger

  def start_link(init_arg) do
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    Horde.DynamicSupervisor.init(
      strategy: :one_for_one,
      members: :auto,
      process_redistribution: :active
    )
  end

  def start_dictionaries do
    dictionary_count = Application.get_env(:tp_iasc, :dictionary_count)
    replication_factor = Application.get_env(:tp_iasc, :replication_factor)

    for i <- 0..dictionary_count - 1 do
      for j <- 1..replication_factor do
        Logger.debug("Starting dictionary #{i} replica #{j}")
        Horde.DynamicSupervisor.start_child(__MODULE__, %{
          id: {:dictionary, i, j},
          start: {Block.Dictionary, :start_link, [{:global, {:block_dictionary, i, j}}]},
          restart: :transient
        })
      end
    end
  end

  def adjust_all_replications do
    dictionary_count = Application.get_env(:tp_iasc, :dictionary_count)
    replication_factor = Application.get_env(:tp_iasc, :replication_factor)
    nodes = Node.list() ++ [Node.self()]
    node_count = length(nodes)

    if node_count < replication_factor do
      Logger.warning("Faltan #{replication_factor - node_count} nodos para alcanzar el factor de replicación deseado.")
    end

    for i <- 0..dictionary_count - 1 do
      replicas = Enum.filter(:global.registered_names(), fn name ->
        case name do
          {:block_dictionary, ^i, _} -> true
          _ -> false
        end
      end)

      Logger.debug("Dictionary #{i} tiene #{length(replicas)} replicas. Deseadas: #{replication_factor}")

      if length(replicas) < replication_factor do
        Logger.warning("El dictionary #{i} tiene menos replicas de las deseadas. Actual: #{length(replicas)}, Deseadas: #{replication_factor}")
        adjust_replication(i, replication_factor - length(replicas))
      else
        Logger.info("El dictionary #{i} tiene el número correcto de réplicas. Actual: #{length(replicas)}, Deseadas: #{replication_factor}")
      end
    end
  end

  defp adjust_replication(dictionary_id, deficit) when deficit > 0 do
    Logger.info("Ajustando la replicación para dictionary #{dictionary_id}. Faltan #{deficit} réplicas.")
    for i <- 1..deficit do
      case Horde.DynamicSupervisor.start_child(__MODULE__, %{
        id: {:dictionary, dictionary_id, i},
        start: {Block.Dictionary, :start_link, [{:global, {:block_dictionary, dictionary_id, i}}]},
        restart: :transient
      }) do
        {:ok, pid} ->
          Logger.info("Replica creada para dictionary #{dictionary_id} con pid #{inspect(pid)}")
        {:error, reason} ->
          Logger.error("Error al crear replica para dictionary #{dictionary_id}: #{inspect(reason)}")
      end
    end
  end

  def handle_info(msg, state) do
    Logger.error("Unhandled message: #{inspect(msg)}")
    {:noreply, state}
  end
end
