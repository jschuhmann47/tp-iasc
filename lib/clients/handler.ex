defmodule Clients.ClientHandler do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/ping" do
    :pong = GenServer.call(get_master(), :ping)
    send_resp(conn, 200, "pong")
  end

  get "/:key" do
    if check_length(key, :key) do
      send_resp(conn, 401, "Key exceeds max length")
    else
      res = GenServer.call(get_master(), {:get, key})

      case res do
        nil -> send_resp(conn, 404, "Not found")
        res -> send_resp(conn, 200, "Got #{res}")
      end
    end
  end

  delete "/:key" do
    GenServer.cast(get_master(), {:delete, key})
    send_resp(conn, 200, "Deleted key '#{key}'")
  end

  get "/lesser/:value" do
    if check_length(value, :value) do
      send_resp(conn, 401, "Value exceeds max length")
    else
      res = GenServer.call(get_master(), {:get_lesser, value})

      case res do
        [] ->
          send_resp(conn, 404, "There are no values lesser than #{value}")

        res ->
          send_resp(conn, 200, "Lesser values than #{value}: #{generate_printable_list(res)}")
      end
    end
  end

  get "/greater/:value" do
    if check_length(value, :value) do
      send_resp(conn, 401, "Key exceeds max length")
    else
      res = GenServer.call(get_master(), {:get_greater, value})

      case res do
        [] ->
          send_resp(conn, 404, "There are no values greater than #{value}")

        res ->
          send_resp(conn, 200, "Values greater than #{value}: #{generate_printable_list(res)}")
      end
    end
  end

  get "/keys/distribution" do
    res = GenServer.call(get_master(), :keys_distribution)
    send_resp(conn, 200, "Key distribution: #{inspect(res)}")
  end

  put "/:key/:value" do
    if check_length(key, :key) or check_length(value, :value) do
      send_resp(conn, 401, "Key or value exceeds max length")
    else
      case GenServer.call(get_master(), {:put, key, value}) do
        :ok ->
          send_resp(conn, 200, "Updated key #{key} with value #{value}")

        _ ->
          send_resp(
            conn,
            500,
            "An error has occurred (see log for details)"
          )
      end
    end
  end

  match _ do
    send_resp(conn, 404, "Route does not exist")
  end

  def get_master() do
    Orchestrators.Orchestrator.via_tuple(Clients.GetMaster.get_master())
  end

  def check_length(str, :key) do
    String.length(str) > Application.get_env(:tp_iasc, :key_length, 10)
  end

  def check_length(str, :value) do
    String.length(str) > Application.get_env(:tp_iasc, :value_length, 10)
  end

  defp generate_printable_list(list) do
    str = Enum.join(list, ", ")
    String.slice(str, 0..(String.length(str) - 1))
  end
end
