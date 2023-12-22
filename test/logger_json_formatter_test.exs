defmodule LoggerJSONFormatterTest do
  use ExUnit.Case
  doctest LoggerJSONFormatter

  test "greets the world" do
    assert LoggerJSONFormatter.hello() == :world
  end
end
