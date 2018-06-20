defmodule Filter.Retrieval do
  alias Filter.Trie

  def new(binaries) when is_list(binaries) do
    insert(%Trie{}, binaries)
  end

  def new(binary) when is_binary(binary) do
    insert(%Trie{}, binary)
  end

  def insert(%Trie{trie: trie}, binaries) when is_list(binaries) do
    %Trie{trie: Enum.reduce(binaries, trie, &_insert(&2, &1))}
  end

  def insert(%Trie{trie: trie}, binary) when is_binary(binary) do
    %Trie{trie: _insert(trie, binary)}
  end

  # defp _insert(trie, binary, index \\ 1)

  defp _insert(trie, <<next, rest::binary>>) do
    case Map.has_key?(trie, next) do
      # |> Map.put(:index, index)
      true ->
        Map.put(trie, next, _insert(trie[next], rest))

      # |> Map.put(:index, index)
      false ->
        Map.put(trie, next, _insert(%{}, rest))
    end
  end

  defp _insert(trie, <<>>) do
    Map.put(trie, :mark, :mark)
    #  |> Map.put(:index, index)
  end

  @doc """
  检查文字中是否有敏感词或疑似敏感词

  参数为接收敏感词集trie，被检查的文字串str，返回命中的词语列表
  """
  def check_words(%Trie{trie: map}, str, hit_list \\ []) when is_binary(str) do
    _check_words(%Trie{trie: map}, map, str, hit_list)
  end

  defp _check_words(trie, map, str, hit_list, check_list \\ [])

  defp _check_words(trie, %{mark: :mark}, str, hit_list, check_list) do
    check_words(trie, str, hit_list ++ [check_list])
  end

  defp _check_words(trie, map, <<key, rest::binary>>, hit_list, check_list) do
    case Map.has_key?(map, key) do
      true ->
        _check_words(trie, map[key], rest, hit_list, check_list ++ [key])

      false ->
        case Enum.any?(check_list) do
          true -> check_words(trie, <<key, rest::binary>>, hit_list)
          false -> check_words(trie, rest, hit_list)
        end
    end
  end

  defp _check_words(_trie, _map, <<>>, hit_list, _check_list) do
    hit_list
  end
end
