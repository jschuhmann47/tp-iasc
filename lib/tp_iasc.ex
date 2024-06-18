defmodule TpIasc do
  use Application

  def start(_type, _args) do
    name_application()
    init_cowboy()
    MainSupervisor.start_link(:ok)
  end

  def name_application() do
    Process.register(self(), TpIasc)
  end

  def init_cowboy() do
    dispatch = :cowboy_router.compile([
      {:_, [{"/", Cliente.ClienteHandler, []}]}
    ])
    {:ok, _} = :cowboy.start_clear(:http,
                          [port: 8080],
                          %{env: [dispatch: dispatch]})
  end
end
