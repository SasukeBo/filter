defmodule FilterTest do
  use ExUnit.Case
  # doctest Filter

  test "filter words" do
    assert Filter.filter_words("某美@#$%国某某是 王 .//]八蛋12355fu\nc )king") ==
             [
               %{content: "美国", id: 2, level: 0},
               %{content: "王八蛋", id: 17, level: 0},
               %{content: "fuck", id: 16, level: 1}
             ]
  end
end
