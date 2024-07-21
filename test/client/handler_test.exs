defmodule TpIascRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Clients.ClientHandler

  @opts ClientHandler.init([])

  test "returns pong" do
    conn =
      :get
      |> conn("/ping")
      |> ClientHandler.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "pong"
  end

  test "asks for value" do
    conn =
      :get
      |> conn("/baz")
      |> ClientHandler.call(@opts)

    assert conn.state == :sent
    # TODO test with data
    assert conn.status == 404
  end

  test "updates a value" do
    conn =
      :put
      |> conn("/foo/bar")
      |> ClientHandler.call(@opts)

    assert conn.state == :sent
    assert conn.status == 202
  end

  test "404 on non existing route" do
    conn =
      :get
      |> conn("/missing")
      |> ClientHandler.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
