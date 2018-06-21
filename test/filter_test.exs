defmodule FilterTest do
  use Filter.EctoCase

  # doctest Filter

  @valid_word %{content: "new_word", level: "10010101"}
  @valid_words [
    %{content: "脏话", level: "00000001"},
    %{content: "淫秽", level: "00000100"},
    %{content: "反动", level: "00000010"}
  ]
  @sentence "过滤用户输入文字中包含的诸如脏话、淫秽、反动等不文明文字缓存可能是提升应用性能最常见的做法和技术，Elixir有许多缓存技术，其中一些非常棒。但是它们许多值关注本地缓存，但是我们面对的情况是，今时今日，我们极少只在单机部署应用，尤其是在 Elixir/Erlang 的世界。大多数情况我们都将处理分布式系统，即至少包含两个节点。也就是说，一个本地缓存不够，我们还需要一个分布式缓存，不仅为我们提供优异的性能，还有线性的横向扩展性，当然，还有能从集群的任何节点获取数据。你可能会想，为何没有一个库能同时实现两者，根据需求创建不同的缓存拓扑，它可以是一个简单的本地缓存，一个分布式的分割的缓存，或者一个就近缓存拓扑。哈哈，这就是Nebulex！

作者：时见疏星
链接：https://www.jianshu.com/p/d93dd69d876b
來源：简书
简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。"

  def word_fixture(attrs) do
    {:ok, word} =
      attrs
      |> Filter.add_word()

    word
  end

  test "all_words/0 returns all words" do
    words = @valid_words |> Enum.map(&word_fixture(&1))
    assert Filter.all_words() == words
  end

  test "add_word/1 with valid data add a word" do
    assert {:ok, %Filter.DirtyWords{} = word} = Filter.add_word(@valid_word)
    assert word.content == "new_word"
    assert word.level == String.to_integer("10010101", 2)
  end

  test "delete_word/1 deletes the word by id" do
    word = word_fixture(@valid_word)
    assert {:ok, %Filter.DirtyWords{}} = Filter.delete_word(word.id)
  end

  test "filter_words/1 returns all dirty words in the sentence" do
    @valid_words |> Enum.map(&word_fixture(&1))
    assert hit_words = Filter.filter_words(@sentence)
    dirty_words = Enum.map(hit_words, fn word -> %{content: word.content, level: word.level} end)
    valid_words = Enum.map(@valid_words, fn word -> %{content: word.content, level: String.to_integer(word.level, 2)} end)
    assert valid_words == dirty_words
  end
end
