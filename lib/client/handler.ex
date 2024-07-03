defmodule Clients.ClientHandler do
  use Plug.Router

  plug(:match)
  plug(:dispatch)
  get "/ping" do
    send_resp(conn, 200, "pong")
  end

  # TODO: communicate with an orchestrator to do real get/put
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
