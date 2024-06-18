defmodule Cliente.ClienteHandler do
  def init(req, state) do
    {:ok, req2} = :cowboy_req.reply(200, ["content-type": "text/plain"],"Hello world!", req)
    {:ok, req2, state}
  end

  # def handle(req, state) do
  #   {:ok, req} = :cowboy_req.reply(200, [], "Hello world!")
  #   {:ok, req, state}
  # end

  def terminate(_reason, _req, _state), do: :ok
end
