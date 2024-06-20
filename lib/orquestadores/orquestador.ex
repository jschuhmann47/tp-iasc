defmodule Orquestadores.Orquestador do
  use GenServer
  require Logger

  @nodo_datos_cantidad 10

  def init(state) do
    {:ok, state}
  end

  def start_link(intial_state, name) do
    GenServer.start_link(__MODULE__, intial_state, name: name)
  end

  def handle_call({:get, key}, _from, state) do
    # TODO: handle errors and etc
    node_number = node_number_from_key(key, @nodo_datos_cantidad)
    value = Bloque.NodoDatosServer.value(node_number, key)
    {:reply, value, state}
  end

  def handle_call(:keys_distribution, _from, state) do
    # Returns all the node numbers and their corresponding keys
    # Useful for debugging
    keys_distribution = Enum.map(0..@nodo_datos_cantidad-1, fn node_number ->
      keys = Bloque.NodoDatosServer.keys(node_number)
      {node_number, keys}
    end)

    {:reply, keys_distribution, state}
  end

  def handle_cast({:put, key, value}, state) do
    node_number = node_number_from_key(key, @nodo_datos_cantidad)
    Bloque.NodoDatosServer.update(node_number, key, value)
    {:noreply, state}
  end

  def node_number_from_key(key, node_quantity) do
    hash = :erlang.phash2(key)
    node_number = rem(hash, node_quantity)
    node_number
  end


end
