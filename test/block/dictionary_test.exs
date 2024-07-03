defmodule TpIascTest do
  use ExUnit.Case
  doctest TpIasc

  test "inserts a key and gets it" do
    Block.Dictionary.start_link(__MODULE__)
    Block.Dictionary.update(__MODULE__, "hola", "chau")
    assert Block.Dictionary.value(__MODULE__, "hola") == "chau"
  end
end
