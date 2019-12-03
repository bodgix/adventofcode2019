defmodule WireGrid do
  def run([path], print) when is_binary(path) do
    [{visited_points1, path1}, {visited_points2, path2}] =
      path
      |> read_file()
      |> Enum.map(&run_wire/1)

    intersections =
      [visited_points1, visited_points2]
      |> cross_points()
      |> MapSet.to_list()

    intersections
    |> Enum.map(&Taxicab.distance({0, 0}, &1))
    |> Enum.sort()
    |> List.first()
    |> (fn result -> print && IO.puts(result) end).()

    {intersections, path1, path2}
  end

  def run(["-2", path], _print) do
    {intersections, path1, path2} = run([path], false)

    intersections
    |> Enum.map(fn point ->
      Enum.find_index(path1, &(&1 == point)) + Enum.find_index(path2, &(&1 == point))
    end)
    |> Enum.sort()
    |> List.first()
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
    do: run_wire(instructions, {MapSet.new(), {0, 0}, [{0, 0}]})

  def run_wire([], {visited_points, _position, path} = _acc), do: {visited_points, path}

  def run_wire([instruction | rest], {visited_points, position, path} = _acc) do
    {new_section, new_position} = draw_path(instruction, position)

    new_visited_points =
      new_section
      |> Enum.into(visited_points)

    new_path = path ++ new_section

    run_wire(rest, {new_visited_points, new_position, new_path})
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
|> WireGrid.run(true)
