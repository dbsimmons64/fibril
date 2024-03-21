defmodule FibrilTest do
  use ExUnit.Case
  doctest Fibril

  test "greets the world" do
    assert Fibril.hello() == :world
  end
end
