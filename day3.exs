defmodule WireGrid do
  def run([path]) when is_binary(path) do
    path
    |> read_file()
    |> Enum.map(&run_wire/1)
    |> cross_points()
    |> MapSet.to_list()
    |> Enum.sort_by(&Taxicab.distance({0, 0}, &1))
    |> List.first()
    |> Taxicab.distance({0, 0})
    |> IO.puts()
  end

  def read_file(path) do
    File.read!(path)
    |> String.split()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_instructions/1)
  end

  def cross_points([wire1, wire2]), do: MapSet.intersection(wire1, wire2)

  def parse_instructions(instructions) do
    instructions
    |> String.split(",")
  end

  def run_wire(instructions) when is_list(instructions),
    do: run_wire(instructions, {MapSet.new(), {0, 0}})

  def run_wire([], {path, _position} = _acc), do: path

  def run_wire([instruction | rest], {path, position} = _acc) do
    {new_section, new_position} = draw_path(instruction, position)

    new_path =
      new_section
      |> Enum.into(path)

    run_wire(rest, {new_path, new_position})
  end

  def draw_path("R" <> len = _instr, {x, y} = _cur_position) do
    len = String.to_integer(len)
    path = for xp <- (x + 1)..(x + len), do: {xp, y}
    {path, {x + len, y}}
  end

  def draw_path("L" <> len = _instr, {x, y} = _cur_position) do
    len = String.to_integer(len)
    path = for xp <- (x - 1)..(x - len), do: {xp, y}
    {path, {x - len, y}}
  end

  def draw_path("U" <> len = _instr, {x, y} = _cur_position) do
    len = String.to_integer(len)
    path = for yp <- (y + 1)..(y + len), do: {x, yp}
    {path, {x, y + len}}
  end

  def draw_path("D" <> len = _instr, {x, y} = _cur_position) do
    len = String.to_integer(len)
    path = for yp <- (y - 1)..(y - len), do: {x, yp}
    {path, {x, y - len}}
  end
end

defmodule Taxicab do
  def distance({x1, y1} = _pt1, {x2, y2} = _pt2), do: abs(x1 - x2) + abs(y1 - y2)
end

System.argv()
|> WireGrid.run()
