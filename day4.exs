defmodule Password do
  def run([start_val, end_val] = args) when is_binary(start_val) and is_binary(end_val) do
    args
    |> Enum.map(&String.to_integer/1)
    |> brute_force(&meets_criteria?/1)
    |> Enum.count()
    |> IO.puts()
  end

  def run(["-2", start_val, end_val] = _args) when is_binary(start_val) and is_binary(end_val) do
    [start_val, end_val]
    |> Enum.map(&String.to_integer/1)
    |> brute_force(&meets_criteria2?/1)
    |> Enum.count()
    |> IO.puts()
  end

  def brute_force([start_val, end_val] = _range, criteria_fn)
      when is_integer(start_val) and is_integer(end_val) do
    last_val = end_val + 1

    Stream.unfold(start_val, fn
      ^last_val -> nil
      prev_val -> {prev_val, prev_val + 1}
    end)
    |> Stream.map(&Integer.to_string/1)
    |> Stream.map(&String.to_charlist/1)
    |> Stream.filter(criteria_fn)
  end

  def meets_criteria?(password) when is_list(password) do
    repeated_letters?(password) && sequence_growing?(password)
  end

  def meets_criteria2?(password) when is_list(password) do
    repeated_letters_twice?(password) && sequence_growing?(password)
  end

  def repeated_letters?(password) when is_list(password) do
    password
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.any?(fn [a, b] -> a == b end)
  end

  def repeated_letters_twice?(password) when is_list(password) do
    password
    |> Enum.chunk_by(& &1)
    |> Enum.filter(&(Enum.count(&1) == 2))
    |> Enum.count() > 0
  end

  def sequence_growing?(password) when is_list(password) do
    password
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [a, b] -> a <= b end)
  end
end

System.argv()
|> Password.run()
