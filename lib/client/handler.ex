defmodule Clients.ClientHandler do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  @orchestrators [Orchestrator1, Orchestrator2, Orchestrator3, Orchestrator4, Orchestrator5]

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

  get "/lesser/:key" do
    res = GenServer.call(get_master(), {:get_lesser, key})

    case res do
      [] -> send_resp(conn, 404, "Not found")
      res -> send_resp(conn, 200, "lesser values for #{key}: #{Enum.join(res, " ")}")
    end
  end

  get "/greater/:key" do
    res = GenServer.call(get_master(), {:get_greater, key})

    case res do
      [] -> send_resp(conn, 404, "Not found")
      res -> send_resp(conn, 200, "greater values for #{key}: #{Enum.join(res, " ")}")
    end
  end

  put "/:key/:value" do
    GenServer.cast(get_master(), {:put, key, value})
    send_resp(conn, 202, "Updated key #{key} with value #{value}")
  end

  match _ do
    send_resp(conn, 404, "Route does not exist")
  end

  def get_master() do
    Enum.find(@orchestrators, fn orchestrator -> GenServer.call(orchestrator, :is_master) end)
  end
end
