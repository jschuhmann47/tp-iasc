defmodule Orquestadores.Orquestador do
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end
end
