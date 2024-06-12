defmodule Bloque.NodoDatos do
  use Agent

  def start_link(name) do
    Agent.start_link(fn -> %{} end, name: name)
  end

  def value(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  def update(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end
end
