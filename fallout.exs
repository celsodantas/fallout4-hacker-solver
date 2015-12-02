defmodule FO4Hacker do

  def all_words_must_have_same_length(words) do
    first_word_length = String.length(List.first(words))

    Enum.each words, fn w ->
      length = String.length(w)
      if length != first_word_length do
        raise "Word '#{w}' have a different size (#{length} chars)"
      end
    end
  end

  def similars(word, candidates) do
    all_words_must_have_same_length(candidates)

    result = Enum.map candidates, fn candidate ->
      if word != candidate do
        c1 = String.split(word, "", trim: true)
        c2 = String.split(candidate, "", trim: true)
        score = score_chars(c1, c2, 0)

        {candidate, score}
      end
    end

    result |> Enum.reject(&(&1 == nil))
  end

  def score_chars([c1 | tail1], [c2 | tail2], score) do
    if c1 == c2 do
      score + score_chars(tail1, tail2, 1)
    else
      score + score_chars(tail1, tail2, 0)
    end
  end

  def score_chars([], [], score), do: score

  def candidates_based_on_likelines(candidate, likeliness, list) do
    similars(candidate, list) |> Enum.filter(&(elem(&1, 1) == likeliness)) |> Enum.map(&(elem(&1, 0)))
  end
end

######
# Enter all strings: size hunt part roll born sets guru wire none core time some sort
# Likeliness for size: 0
# Then select one of these words:
# hunt part roll born guru
# Word and Likeliness: hunt 0

defmodule UI do
  def init do
    IO.puts "Welcome to FO4Hacker"
    input = IO.gets "Please, enter the list of words displayed on the terminal: "

    candidates = input |> String.strip |> String.split(" ", trim: true)
    loop_inputs(candidates)
  end

  def loop_inputs(candidates) do
    input = IO.gets "Word and Likeliness: " |> String.strip

    case input do
      "" ->
        IO.puts "Exiting..."
      _ ->
        [candidate, likeliness]  = input |> String.split(" ", trim: true)
        likeliness = likeliness |> String.strip |> String.to_integer(10)

        candidates = FO4Hacker.candidates_based_on_likelines(candidate, likeliness, candidates)

        IO.puts "Then select one of these words: "
        IO.inspect candidates

        loop_inputs(candidates)
    end
  end
end

UI.init

ExUnit.start
defmodule Tests do
  use ExUnit.Case, async: true

  test "should fail if all words don't have the same size" do
    words = ["creating", "breaking", "gua", "document",
             "greeting", "dynamite"]

    assert_raise RuntimeError, fn ->
      FO4Hacker.similars("creating", words)
    end
  end

  test "should select all other words if likeliness is 0" do
    # correct word: born
    candidates = ["size", "hunt", "part", "roll", "born", "sets", "guru",
                  "wire", "none", "core", "time", "some", "sort"]

    candidate = "size"
    likeliness = 0

    result   = FO4Hacker.candidates_based_on_likelines(candidate, likeliness, candidates)
    expected = ["hunt", "part", "roll", "born", "guru"]

    set1 = Set.put HashSet.new, result
    set2 = Set.put HashSet.new, expected

    assert result == expected
    assert Set.equal? set1, set2
  end

  test "should select words >= equal chars based on likeliness" do
    # correct word: born
    candidates = ["size", "hunt", "part", "roll", "born", "sets", "guru",
                  "wire", "none", "core", "time", "some", "sort"]

    candidate = "sort"
    likeliness = 2

    result   = FO4Hacker.candidates_based_on_likelines(candidate, likeliness, candidates)
    expected = ["part", "born", "core", "some"]

    set1 = Set.put HashSet.new, result
    set2 = Set.put HashSet.new, expected

    assert result == expected
    assert Set.equal? set1, set2
  end
end
