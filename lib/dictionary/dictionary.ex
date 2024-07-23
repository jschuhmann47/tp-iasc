defmodule Block.Dictionary do
  use Agent
  require Logger

  @block_dictionary_registry TpIasc.Registry

  def start_link({name, id, replica}) do
    via_name = via_tuple({name, id, replica})
    replicated_data = get_data_if_replica_exists(id, replica)
    Logger.info("Dictionary started with name: #{inspect(via_name)}")
    Agent.start_link(fn -> replicated_data end, name: via_name)
  end

  def value(agent, key) do
    Logger.debug("Dictionary(#{inspect(agent)}) getting key: #{inspect(key)}")
    Agent.get(agent, &Map.get(&1, key))
  end

  def lesser(agent, value) do
    Logger.debug("Dictionary(#{inspect(agent)}) getting values lesser than: #{inspect(value)}")
    Agent.get(agent, &Map.values(:maps.filter(fn _, v -> v < value end, &1)))
  end

  def greater(agent, value) do
    Logger.debug("Dictionary(#{inspect(agent)}) getting values greater than: #{inspect(value)}")
    Agent.get(agent, &Map.values(:maps.filter(fn _, v -> v > value end, &1)))
  end

  def update(agent, key, value) do
    if exceeds_limit_if_new_key_is_inserted?(agent) do
      Logger.warning(
        "Dictionary(#{inspect(agent)}) is at max capacity. Not inserting key #{inspect(key)} with value #{inspect(value)}"
      )

      :limit_reached
    else
      Logger.debug(
        "Dictionary(#{inspect(agent)}) updating key: #{inspect(key)} with value #{inspect(value)}"
      )

      Agent.update(agent, &Map.put(&1, key, value))
    end
  end

  def delete(agent, key) do
    Logger.debug("Dictionary(#{inspect(agent)}) deleting key: #{inspect(key)}")
    Agent.update(agent, &Map.delete(&1, key))
  end

  def keys(agent) do
    Agent.get(agent, &Map.keys(&1))
  end

  def values(agent) do
    Agent.get(agent, &Map.values(&1))
  end

  def get_map(agent) do
    Agent.get(agent, & &1)
  end

  defp exceeds_limit_if_new_key_is_inserted?(agent) do
    key_count = Agent.get(agent, &length(Map.keys(&1)))
    key_count + 1 > floor(TpIasc.Helpers.get_database_capacity())
  end

  def via_tuple(name), do: {:via, Horde.Registry, {@block_dictionary_registry, name}}

  def get_data_if_replica_exists(id, replica) do
    name =
      TpIasc.Helpers.list_dictionaries()
      |> Enum.find(fn x ->
        case x do
          {:block_dictionary, n, r} when n == id and r != replica -> true
          _ -> false
        end
      end)

    if name != nil do
      Block.Dictionary.get_map(via_tuple(name))
    else
      %{}
    end
  end
end
