defmodule Clients.ClientHandler do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/ping" do
    :pong = GenServer.call(Orchestrator1, {:ping})
    send_resp(conn, 200, "pong")
  end

  get "/:key" do
    send_resp(conn, 200, "Got #{key}")
  end

  put "/:key/:value" do
    send_resp(conn, 201, "Updated key #{key} with value #{value}")
  end

  match _ do
    send_resp(conn, 404, "Route does not exist")
  end
end
