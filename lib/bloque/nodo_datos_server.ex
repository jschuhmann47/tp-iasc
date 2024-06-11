defmodule Bloque.NodoDatosServer do
  alias Bloque.NodoDatos
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def start_link(name) do
    GenServer.start_link(name, %{})
  end

  def handle_call({:get, key}, _from, state) do
    value = NodoDatos.value("nodo1", key)
    {:reply, value, state}
  end

  def handle_cast({:put, key, value}, state) do
    NodoDatos.update("nodo1", key, value)
    {:noreply, state}
  end
end
