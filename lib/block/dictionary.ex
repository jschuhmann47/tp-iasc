defmodule Block.Dictionary do
  use Agent
  require Logger

  @block_dictionary_registry TpIasc.Registry

  def start_link({id, replica}) do
    name = via_tuple({:block_dictionary, id, replica})
    Logger.info("Dictionary started with name: #{inspect(name)}")
    Agent.start_link(fn -> %{} end, name: name)
  end

  def value(agent, key) do
    Logger.debug("Dictionary(#{inspect(agent)}) getting key: #{inspect(key)}")
    Agent.get(agent, &Map.get(&1, key))
  end

  def update(agent, key, value) do
    Logger.debug("Dictionary(#{inspect(agent)}) updating key: #{inspect(key)} with value: #{inspect(value)}")
    Agent.update(agent, &Map.put(&1, key, value))
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

  def via_tuple({:block_dictionary, id, replica}), do: {:via, Horde.Registry, {@block_dictionary_registry, {:block_dictionary, id, replica}}}
  def via_tuple({:block_dictionary, id}), do: {:via, Horde.Registry, {@block_dictionary_registry, {:block_dictionary, id}}}
end
