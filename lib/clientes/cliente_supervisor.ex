defmodule Cliente.ClienteSupervisor do
  use Supervisor

  def start_link(_etc) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = []
    Supervisor.init(children, strategy: :one_for_one)
  end
end
