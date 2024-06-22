defmodule TpIasc do
  require Logger
  use Application

  def start(_type, _args) do
    configure_logging()
    name_application()
    MainSupervisor.start_link(:ok)
  end

  def name_application() do
    Process.register(self(), TpIasc)
  end

  defp configure_logging() do
    log_level = Application.get_env(:tp_iasc, :log_level, :info)
    Logger.configure(level: log_level)
    Logger.info("Starting TpIasc with log level #{log_level}")
  end
end
