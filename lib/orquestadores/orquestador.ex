defmodule Orquestadores.Orquestador do
  use GenServer
  require Logger

  def init({state, nodo_datos_cantidad}) do
    {:ok, %{state: state, nodo_datos_cantidad: nodo_datos_cantidad}}
  end

  def start_link(initial_state, nodo_datos_cantidad, name) do
    GenServer.start_link(__MODULE__, {initial_state, nodo_datos_cantidad}, name: name)
  end

  def handle_call({:get, key}, _from, state_data) do
    %{state: _, nodo_datos_cantidad: nodo_datos_cantidad} = state_data
    node_number = node_number_from_key(key, nodo_datos_cantidad)
    value = Bloque.NodoDatosServer.value(node_number, key)
    {:reply, value, state_data}
  end

  def handle_call(:keys_distribution, _from, state_data) do
    %{state: _, nodo_datos_cantidad: nodo_datos_cantidad} = state_data
    keys_distribution = Enum.map(0..nodo_datos_cantidad-1, fn node_number ->
      keys = Bloque.NodoDatosServer.keys(node_number)
      {node_number, keys}
    end)
    {:reply, keys_distribution, state_data}
  end

  def handle_cast({:put, key, value}, state_data) do
    %{state: _, nodo_datos_cantidad: nodo_datos_cantidad} = state_data
    node_number = node_number_from_key(key, nodo_datos_cantidad)
    Bloque.NodoDatosServer.update(node_number, key, value)
    {:noreply, state_data}
  end

  def node_number_from_key(key, node_quantity) do
    hash = :erlang.phash2(key)
    node_number = rem(hash, node_quantity)
    node_number
  end
end
