defmodule Clients.ClientHandler do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  @orchestrators [Orchestrator1, Orchestrator2, Orchestrator3, Orchestrator4, Orchestrator5]

  # https://hexdocs.pm/plug/1.16.0/Plug.Router.html#module-passing-data-between-routes-and-plugs
  get "/ping" do
    master = Enum.find(@orchestrators, fn orchestrator -> GenServer.call(orchestrator, :is_master) end)
    :pong = GenServer.call(master, :ping)
    send_resp(conn, 200, "pong from #{Atom.to_string(master)}")
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
