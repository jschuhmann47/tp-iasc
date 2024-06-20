defmodule Orquestadores.Orquestador do
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def start_link(intial_state, name) do
    GenServer.start_link(__MODULE__, intial_state, name: name)
  end


  def handle_call({:get, key}, _from, state) do
    # TODO: handle errors and etc
    value = Bloque.NodoDatosServer.value(4, key) # TODO: por ahora de manera arbitraria leo y escribo en el nodo 4
    {:reply, value, state}
  end

  def handle_cast({:put, key, value}, state) do

    Bloque.NodoDatosServer.update(4, key, value) # TODO: por ahora de manera arbitraria leo y escribo en el nodo 4
    {:noreply, state}
  end
end
