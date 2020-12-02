defmodule AntijackbotTest do
  use ExUnit.Case
  doctest Antijackbot

  test "greets the world" do
    assert Antijackbot.hello() == :world
  end
end
