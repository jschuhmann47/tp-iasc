defmodule TpIascTest do
  use ExUnit.Case
  doctest TpIasc

  test "inserts a key and gets it" do
    Bloque.NodoDatos.start_link(__MODULE__)
    Bloque.NodoDatos.update("hola", "chau")
    assert Bloque.NodoDatos.value("hola") == "chau"
  end
end
