defmodule TpIascTest do
  use ExUnit.Case
  doctest TpIasc

  test "inserts a key and gets it" do
    Bloque.NodoDatos.start_link(__MODULE__)
    Bloque.NodoDatos.update(__MODULE__, "hola", "chau")
    assert Bloque.NodoDatos.value(__MODULE__, "hola") == "chau"
  end
end
