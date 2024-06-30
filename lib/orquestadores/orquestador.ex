defmodule Orquestadores.Orquestador do
  use GenServer
  require Logger

  @nodo_datos_registry_name TpIasc.Registry

  def start_link(initial_state, nodo_datos_cantidad, name) do
    GenServer.start_link(__MODULE__, {initial_state, nodo_datos_cantidad}, name: name)
  end

  def init({state, nodo_datos_cantidad}) do
    {:ok, %{state: state, nodo_datos_cantidad: nodo_datos_cantidad}}
  end

  def handle_call({:get, key}, _from, state_data) do
    %{nodo_datos_cantidad: nodo_datos_cantidad} = state_data
    node_number = node_number_from_key(key, nodo_datos_cantidad)
    case Horde.Registry.lookup(@nodo_datos_registry_name, node_number) do
      [{pid, _value}] ->
        value = GenServer.call(pid, {:get, key})
        {:reply, value, state_data}
      [] ->
        {:reply, :not_found, state_data}
    end
  end

  def handle_call(:keys_distribution, _from, state_data) do
    %{nodo_datos_cantidad: nodo_datos_cantidad} = state_data
    keys_distribution = Enum.map(0..nodo_datos_cantidad-1, fn node_number ->
      keys = Bloque.NodoDatosServer.keys(node_number)
      {node_number, keys}
    end)
    {:reply, keys_distribution, state_data}
  end

  def handle_cast({:put, key, value}, state_data) do
    %{nodo_datos_cantidad: nodo_datos_cantidad} = state_data
    node_number = node_number_from_key(key, nodo_datos_cantidad)
    case Horde.Registry.lookup(@nodo_datos_registry_name, node_number) do
      [{pid, _value}] ->
        GenServer.cast(pid, {:put, key, value})
        {:noreply, state_data}
      [] ->
        Logger.error("No process found for node_number #{node_number}")
        {:noreply, state_data}
    end
  end

  def node_number_from_key(key, node_quantity) do
    :erlang.phash2(key, node_quantity)
  end
end
