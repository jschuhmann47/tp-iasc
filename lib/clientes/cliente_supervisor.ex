defmodule Cliente.ClienteSupervisor do
  use Supervisor

  def start_link(_etc) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_arg) do
    children = [
      # %{
      #   id: Cliente.ClienteHandler,
      #   start: {Cliente.ClienteHandler, :start_link, [Cliente.ClienteHandler]},
      #   restart: :transient
      # },
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
