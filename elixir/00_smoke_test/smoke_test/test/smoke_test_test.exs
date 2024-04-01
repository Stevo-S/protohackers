defmodule SmokeTestTest do
  use ExUnit.Case
  doctest SmokeTest

  test "greets the world" do
    assert SmokeTest.hello() == :world
  end

  test "implements Application behaviour" do
    assert function_exported?(SmokeTest, :start, 2)
  end
end
