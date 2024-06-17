defmodule Bloque.NodoDatos do
  use Agent

  def start_link(name) do
    Agent.start_link(fn -> %{} end, name: name)
  end

  def value(agent, key) do
    Agent.get(agent, &Map.get(&1, key))
  end

  def update(agent, key, value) do
    Agent.update(agent, &Map.put(&1, key, value))
  end
end
