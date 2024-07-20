defmodule Block.DictionarySupervisor do
  use Horde.DynamicSupervisor
  require Logger

  def start_link(init_arg) do
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(child_spec) do
    Horde.DynamicSupervisor.start_child(TpIasc.DistributedSupervisor, child_spec)
  end

  def init(_init_arg) do
    Horde.DynamicSupervisor.init(
      strategy: :one_for_one,
      distribution_strategy: Horde.UniformQuorumDistribution,
      process_redistribution: :active,
      members: :auto
    )
  end

  def start_dictionaries do
    if TpIasc.Helpers.list_dictionaries() == [] do
      dictionary_count = Application.get_env(:tp_iasc, :dictionary_count, 10)
      replication_factor = Application.get_env(:tp_iasc, :replication_factor, 3)

      children =
        for i <- 0..(dictionary_count - 1) do
          for j <- 1..replication_factor do
            Logger.debug("Starting dictionary #{i} replica #{j}")

            %{
              id: {:block_dictionary, i, j},
              start: {Block.Dictionary, :start_link, [{:block_dictionary, i, j}]},
              restart: :transient
            }
          end
        end

      List.flatten(children)
      |> Enum.each(&start_child/1)
    end
  end

  def adjust_all_replications do
    dictionary_count = Application.get_env(:tp_iasc, :dictionary_count)
    replication_factor = Application.get_env(:tp_iasc, :replication_factor)
    nodes = Node.list() ++ [Node.self()]
    node_count = length(nodes)

    if node_count < replication_factor do
      Logger.warning(
        "There are #{replication_factor - node_count} nodes missing to reach replication factor."
      )
    end

    for i <- 0..(dictionary_count - 1) do
      replicas =
        Enum.filter(:global.registered_names(), fn name ->
          case name do
            {:block_dictionary, ^i, _} -> true
            _ -> false
          end
        end)

      Logger.debug(
        "Dictionary #{i} has #{length(replicas)} replicas. Wanted: #{replication_factor}"
      )

      if length(replicas) < replication_factor do
        Logger.warning(
          "Dictionary #{i} has less replicas than wanted. Actual: #{length(replicas)}, Wanted: #{replication_factor}"
        )

        adjust_replication(i, replication_factor, replicas)
      else
        Logger.info(
          "Dictionary #{i} has wanted replica count. Actual: #{length(replicas)}, Wanted: #{replication_factor}"
        )
      end
    end
  end

  defp adjust_replication(dictionary_id, replication_factor, existing_replicas) do
    existing_replica_ids =
      Enum.map(existing_replicas, fn {:block_dictionary, ^dictionary_id, replica_id} ->
        replica_id
      end)

    desired_replica_ids = Enum.to_list(1..replication_factor)

    missing_replica_ids =
      Enum.filter(desired_replica_ids, fn id -> id not in existing_replica_ids end)

    Logger.info(
      "Adjusting replication for dictionary #{dictionary_id}. Missing #{length(missing_replica_ids)} replicas."
    )

    for replica_id <- missing_replica_ids do
      case Horde.DynamicSupervisor.start_child(__MODULE__, %{
             id: {:block_dictionary, dictionary_id, replica_id},
             start:
               {Block.Dictionary, :start_link, [{:block_dictionary, dictionary_id, replica_id}]},
             restart: :transient
           }) do
        {:ok, pid} ->
          Logger.info("Replica created for dictionary #{dictionary_id} with pid #{inspect(pid)}")

        {:error, reason} ->
          Logger.error(
            "Error creating replica for dictionary #{dictionary_id}: #{inspect(reason)}"
          )
      end
    end
  end

  def handle_info(msg, state) do
    Logger.error("Unhandled message: #{inspect(msg)}")
    {:noreply, state}
  end
end
