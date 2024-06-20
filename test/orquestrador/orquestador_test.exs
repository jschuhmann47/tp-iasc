defmodule Orquestadores.OrquestadorTest do
  use ExUnit.Case, async: true

  alias Orquestadores.Orquestador

  setup do
    {:ok, pid} = Orquestador.start_link(%{}, 10, :orquestador_test)
    %{pid: pid}
  end

  test "puts and gets a value", %{pid: pid} do
    GenServer.cast(pid, {:put, :key1, "value1"})
    :timer.sleep(100)  # Give some time for the cast to be processed
    value = GenServer.call(pid, {:get, :key1})
    assert value == "value1"
  end

  test "returns keys distribution", %{pid: pid} do
    GenServer.cast(pid, {:put, :key1, "value1"})
    GenServer.cast(pid, {:put, :key2, "value2"})
    :timer.sleep(100)  # Give some time for the casts to be processed

    keys_distribution = GenServer.call(pid, :keys_distribution)
    assert is_list(keys_distribution)
    assert Enum.any?(keys_distribution, fn {_, keys} -> :key1 in keys end)
    assert Enum.any?(keys_distribution, fn {_, keys} -> :key2 in keys end)
  end

  test "handles non-existing key gracefully", %{pid: pid} do
    value = GenServer.call(pid, {:get, :non_existing_key})
    assert value == nil
  end
end
