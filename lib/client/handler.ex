defmodule Clients.ClientHandler do
  alias Client.OrchestratorCaller
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "pong")
  end

  get "/:key" do
    res = OrchestratorCaller.get_key(key)
    send_resp(conn, 200, "Got #{res}")
  end

  put "/:key/:value" do
    OrchestratorCaller.put_key(key, value)
    send_resp(conn, 201, "Updated key #{key} with value #{value}")
  end

  match _ do
    send_resp(conn, 404, "Route does not exist")
  end
end
