defmodule Clients.ClientHandler do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  @orchestrators [Orchestrator1, Orchestrator2, Orchestrator3, Orchestrator4, Orchestrator5]

  # https://hexdocs.pm/plug/1.16.0/Plug.Router.html#module-passing-data-between-routes-and-plugs
  get "/ping" do
    :pong = GenServer.call(get_master(), :ping)
    send_resp(conn, 200, "pong")
  end

  get "/:key" do
    res = GenServer.call(get_master(), {:get, key})
    case res do
      nil -> send_resp(conn, 404, "Not found")
      res -> send_resp(conn, 200, "Got #{res}")
    end
  end

  put "/:key/:value" do
    GenServer.cast(get_master(), {:put, key, value})
    send_resp(conn, 201, "Updated key #{key} with value #{value}")
  end

  match _ do
    send_resp(conn, 404, "Route does not exist")
  end

  def get_master() do
    Enum.find(@orchestrators, fn orchestrator -> GenServer.call(orchestrator, :is_master) end)
  end
end
