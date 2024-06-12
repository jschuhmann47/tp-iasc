defmodule Bloque.NodoDatosServer do
  alias Bloque.NodoDatos
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def handle_call({:get, name, key}, _from, state) do
    value = NodoDatos.value(name, key)
    {:reply, value, state}
  end

  def handle_cast({:put, name, key, value}, state) do
    NodoDatos.update(name, key, value)
    {:noreply, state}
  end
end
