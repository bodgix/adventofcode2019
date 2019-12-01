defmodule FuelCalculator do
  def calculate_simple(mass), do: fuel_for_mass(mass)

  def calculate_accurate(mass), do: calculate_accurate(mass, 0)

  defp calculate_accurate(0, acc), do: acc

  defp calculate_accurate(mass, acc) do
    fuel_mass =
      mass
      |> fuel_for_mass()

    calculate_accurate(fuel_mass, acc + fuel_mass)
  end

  defp fuel_for_mass(mass) do
    mass
    |> conversion_function()
    |> max(0)
  end

  defp conversion_function(mass), do: div(mass, 3) - 2
end

input_stream =
  File.stream!("day1.txt")
  |> Stream.map(fn line ->
    {mass, _rem} = Integer.parse(line)
    mass
  end)

input_stream
|> Stream.map(&FuelCalculator.calculate_simple/1)
|> Enum.sum()
|> IO.inspect(label: "Part 1")

input_stream
|> Stream.map(&FuelCalculator.calculate_accurate/1)
|> Enum.sum()
|> IO.inspect(label: "Part 2")
