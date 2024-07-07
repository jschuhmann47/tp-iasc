defmodule TpIascRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Clients.ClientHandler

  @opts ClientHandler.init([])

  test "returns pong" do
    conn =
      :get
      |> conn("/ping", "")
      |> ClientHandler.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "pong"
  end

  test "returns a value" do
    conn =
      :get
      |> conn("/foo", "")
      |> ClientHandler.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Got foo"
  end

  test "updates a value" do
    conn =
      :put
      |> conn("/foo/bar")
      |> ClientHandler.call(@opts)

    assert conn.state == :sent
    assert conn.status == 201
  end

  test "returns 404" do
    conn =
      :get
      |> conn("/missing", "")
      |> ClientHandler.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
