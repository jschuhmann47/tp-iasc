defmodule Orquestadores.Orquestador do
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def handle_call({:get, key}, _from, state) do
    {_res, value, _state} = GenServer.call(Bloque.NodoDatosServer, {:get, key})
    {:reply, value, state}
  end

  def handle_cast({:put, key, value}, state) do
    GenServer.cast(Bloque.NodoDatosServer, {:put, key, value})
    {:noreply, state}
  end
end
