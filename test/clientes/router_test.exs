defmodule TpIascRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Clientes.ClienteHandler

  @opts ClienteHandler.init([])

  test "returns welcome" do
    conn =
      :get
      |> conn("/", "")
      |> ClienteHandler.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Welcome"
  end

  test "returns uploaded" do
    conn =
      :put
      |> conn("/")
      |> ClienteHandler.call(@opts)

    assert conn.state == :sent
    assert conn.status == 201
  end

  test "returns 404" do
    conn =
      :get
      |> conn("/missing", "")
      |> ClienteHandler.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
