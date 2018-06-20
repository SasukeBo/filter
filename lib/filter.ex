defmodule Filter do
  import Ecto.Query, only: [from: 1]
  alias Filter.DirtyWords
  alias Filter.Cache
  alias Filter.Retrieval
  alias Filter.Repo

  @moduledoc """
  Documentation for Filter.
  """

  @doc """
    添加敏感词

    ## Examples

      iex> Filter.add_words([%{content: "abc", level: 0}])
      :ok
  """
  def add_words(words_list) do
    init()

    Enum.each(words_list, fn word ->
      case insert_word(word) do
        {:ok, word} -> Cache.set(word.content, word)
      end
    end)
  end

  @doc """
    删除敏感词
    传入敏感词id，返回删除的敏感词内容。

    ## Examples

      iex> Filter.delete_word(19)
      "abc"
  """
  def delete_word(id) do
    init()
    word = Repo.get!(DirtyWords, id)

    case Repo.delete(word) do
      {:ok, struct} -> Cache.delete(struct.content)
    end
  end

  @doc """
    返回所有敏感词列表

    ## Examples

      iex> Filter.all_words
      [
        %{content: "中国", id: 1, level: 1},
        %{content: "美国", id: 2, level: 0},
        %{content: "英国", id: 4, level: 0}
      ]
  """
  def all_words do
    from(DirtyWords)
    |> Filter.Repo.all()
    |> Enum.map(fn word -> %{id: word.id, content: word.content, level: word.level} end)
  end

  @doc """
    按照敏感词集过滤文字中的敏感词汇，返回命中的敏感词列表

    ## Examples

      iex> Filter.filter_words("美。国，王八@ 蛋")
      [
         %{content: "美国", id: 2, level: 0},
         %{content: "王八蛋", id: 17, level: 0}
      ]
  """
  def filter_words(words) do
    init()
    |> Retrieval.check_words(transform_in(words))
    |> transform_out()
    |> Enum.map(fn word -> Cache.get(word) end)
    |> Enum.map(fn word -> %{id: word.id, content: word.content, level: word.level} end)
  end

  defp transform_in(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[，？。、,<>~!@#%&\*\$\^\(\)\{\}\[\]\/\\\|\-\+_=\.\?\s\n]/, "")
    |> IO.inspect()
  end

  defp transform_out(lists) do
    Enum.map(lists, fn list -> Enum.reduce(list, <<>>, fn bit, acc -> acc <> <<bit>> end) end)
  end

  defp insert_word(word) do
    %DirtyWords{}
    |> DirtyWords.changeset(word)
    |> Repo.insert()
  end

  @doc """
    初始化敏感词Trie
    若Cache不为空则直接生成Trie树，否则先加载数据库到Cache中再生成Trie树。

    ## Examples

      iex> Filter.init()
      %Filter.Trie{
        trie:%{...}
      }
  """
  def init do
    case map_size(Cache.to_map()) do
      0 ->
        init_cache()

      _ ->
        create_trie()
    end
  end

  defp init_cache do
    all_words()
    |> Enum.each(fn word -> Cache.set(word.content, word) end)

    create_trie()
  end

  defp create_trie do
    Retrieval.new(words_list())
  end

  defp words_list do
    Cache.to_map()
    |> Enum.map(fn {_key, value} -> value.content end)
  end
end
