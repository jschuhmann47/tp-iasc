defmodule Cliente.ClienteHandler do
  import Plug.Conn

  def init(options), do: options

  def call(req, state) do
    req
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello World!\n")
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state), do: :ok
end
