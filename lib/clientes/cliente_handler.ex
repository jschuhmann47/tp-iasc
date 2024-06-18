defmodule Cliente.ClienteHandler do
  def init(req, state) do
    handle(req, state)
  end

  # def start_link() do

  # end

  def handle(req, state) do
    {:ok, req2} = :cowboy_req.reply(200, ["content-type": "text/plain"], "Hello world!", req)
    {:ok, req2, state}
  end

  def terminate(_reason, _req, _state), do: :ok
end

#  [error] Ranch listener :http, connection process #PID<0.257.0>, stream 1 had its request process #PID<0.258.0> exit with reason :function_clause
