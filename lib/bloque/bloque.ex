defmodule Bloque do
  use Application

  def start(_type, _args) do
    # name_application() // TODO
    Bloque.NodoDatosSupervisor.start_link(:ok)
  end

  def name_application() do
    Process.register(self(), Bloque)
  end

end
