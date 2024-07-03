defmodule Clients.ClientHandler do
  use Plug.Router

  @master Orchestrators.Orchestrator

  # untested, but something like this (don't know how to inject these orchestrators)
  def init(orchestrators) do
    @master = Enum.filter(orchestrators, fn {pid, _} -> GenServer.call(pid, :is_master) end) |> List.first()
  end

  plug(:match)
  plug(:dispatch)
  get "/ping" do
    send_resp(conn, 200, "pong")
  end

  get "/:key" do
    res = GenServer.call(@master, {:get, key})
    send_resp(conn, 200, "Got #{res}")
  end

  put "/:key/:value" do
    GenServer.cast(@master, {:put, key, value})
    send_resp(conn, 201, "Updated key #{key} with value #{value}")
  end

  match _ do
    send_resp(conn, 404, "Route does not exist")
  end
end
