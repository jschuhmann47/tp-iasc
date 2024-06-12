defmodule TpIasc do
  use Application
  @moduledoc """
  Documentation for `TpIasc`.
  """

  def start(_type, _args) do
    name_application()
    SupervisorBloques.start_link(:ok)
    Bloque.start(:ok, :ok)
  end

  def name_application() do
    Process.register(self(), TpIasc)
  end

  @doc """
  Hello world.

  ## Examples

      iex> TpIasc.hello()
      :world

  """
  def hello do
    IO.puts("hello")
    IO.puts("world")
    :world
  end
end
