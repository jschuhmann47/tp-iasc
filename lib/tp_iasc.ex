defmodule TpIasc do
  use Application

  def start(_type, _args) do
    name_application()
    MainSupervisor.start_link(:ok)
  end

  def name_application() do
    Process.register(self(), TpIasc)
  end
end
