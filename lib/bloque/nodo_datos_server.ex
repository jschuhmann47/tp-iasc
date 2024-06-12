defmodule Bloque.NodoDatosServer do
  alias Bloque.NodoDatos
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def handle_call({:get, key}, _from, state) do
    value = NodoDatos.value(key)
    {:reply, value, state}
  end

  def handle_cast({:put, key, value}, state) do
    NodoDatos.update(key, value)
    {:noreply, state}
  end
end

# GenServer.call(Orquestadores.Orquestador, {:get, NodoDatos, "a"})
# GenServer.cast(Orquestadores.Orquestador, {:put, "a", "b"})
# GenServer.call(Orquestadores.Orquestador, {:get, "a"})
