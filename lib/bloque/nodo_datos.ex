defmodule Bloque.NodoDatos do
  use Agent
  require Logger

  def start_link(name) do
    Logger.info("NodoDatos started with name: #{inspect(name)}")
    Agent.start_link(fn -> %{} end, name: name)
  end

  def value(agent, key) do
    Logger.debug("NodoDatos(#{inspect(agent)}) getting key: #{inspect(key)}")
    Agent.get(agent, &Map.get(&1, key))
  end

  def update(agent, key, value) do
    Logger.debug(
      "NodoDatos(#{inspect(agent)}) updating key: #{inspect(key)} with value: #{inspect(value)}"
    )

    Agent.update(agent, &Map.put(&1, key, value))
  end

  def delete(agent, key) do
    Logger.debug("NodoDatos(#{inspect(agent)}) deleting key: #{inspect(key)}")
    Agent.update(agent, &Map.delete(&1, key))
  end

  def keys(agent) do
    Agent.get(agent, &Map.keys(&1))
  end

  def values(agent) do
    Agent.get(agent, &Map.values(&1))
  end
end
