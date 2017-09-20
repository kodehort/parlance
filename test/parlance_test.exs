defmodule ParlanceTest do
  use ExUnit.Case
  doctest Parlance

  test "greets the world" do
    assert Parlance.hello() == :world
  end
end
