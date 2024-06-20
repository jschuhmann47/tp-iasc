defmodule Cliente.ClienteHandler do
  import Plug.Conn

  def init([]) do
    {:ok, []}
  end

  # def handle(req, state) do
  #   {:ok, req2} = :cowboy_req.reply(200, ["content-type": "text/plain"], "Hello world!", req)
  #   {:ok, req2, state}
  # end

  def call(req, state) do
    req
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello World!\n")
    # Map.put(req, "resp_headers", Enum.at(headers, 0))
    # el tema que falla porque req_headers es un array con el map, y quiero solo el map
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state), do: :ok
end

#  [error] Ranch listener :http, connection process #PID<0.257.0>, stream 1 had its request process #PID<0.258.0> exit with reason :function_clause
