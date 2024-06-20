defmodule Bloque.NodoDatosServer do
  use GenServer

  @nodo_datos_registry_name :nodo_datos_registry

  def init(node_id) do
    {:ok, node_id}
  end

  def start_link(node_id) do
    GenServer.start_link(__MODULE__, node_id, name: {:via, Registry, {@nodo_datos_registry_name, node_id}})
  end

  def child_spec({node_id}) do
    %{
      id: {:bloque_nodo_datos_server, node_id},
      start: {__MODULE__, :start_link, [node_id]},
      type: :worker,
      restart: :transient
    }
  end

  defp via_tuple(node_id), do: {:via, Registry, {@nodo_datos_registry_name, node_id}}

  def value(node_id, key) do
    GenServer.call(via_tuple(node_id), {:get, key})
  end

  def update(node_id, key, value) do
    GenServer.cast(via_tuple(node_id), {:put, key, value})
  end

  def handle_call({:get, key}, _from, node_id) do
    value = Bloque.NodoDatos.value({:global, {:nodo_datos, node_id}}, key)
    {:reply, value, node_id}
  end

  def handle_cast({:put, key, value}, node_id) do
    Bloque.NodoDatos.update({:global, {:nodo_datos, node_id}}, key, value)
    {:noreply, node_id}
  end
end

# GenServer.call(Orquestadores.Orquestador, {:get, NodoDatos, "a"})
# GenServer.cast(Orquestadores.Orquestador, {:put, "a", "b"})
# GenServer.call(Orquestadores.Orquestador, {:get, "a"})
