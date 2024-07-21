defmodule TpIascTest do
  use ExUnit.Case
  doctest TpIasc

  test "inserts a key and gets it" do
    Block.Dictionary.start_link({:block_dictionary, 1, 1})

    Block.Dictionary.update(
      {:via, Horde.Registry, {TpIasc.Registry, {:block_dictionary, 1, 1}}},
      "hola",
      "chau"
    )

    assert Block.Dictionary.value(
             {:via, Horde.Registry, {TpIasc.Registry, {:block_dictionary, 1, 1}}},
             "hola"
           ) == "chau"
  end
end
