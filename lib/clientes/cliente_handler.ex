defmodule Cliente.ClienteHandler do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  put "/" do
    send_resp(conn, 200, "Updated key")
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
