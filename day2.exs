defmodule IntcodeComputer do
  defstruct pc: 0,
            memory: %{},
            value: nil

  def new(), do: %__MODULE__{}

  def new(path) do
    memory_txt =
      path
      |> File.read!()
      |> String.trim()

    new()
    |> load_instructions(memory_txt)
  end

  def dump_memory(%{memory: memory} = _computer), do: memory

  def load_instructions(computer, instructions) when is_binary(instructions) do
    new_memory =
      instructions
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {value, addr}, acc -> Map.put(acc, addr, value) end)

    %{computer | memory: new_memory}
  end

  def run(%__MODULE__{} = computer) do
    computer
    |> run_instructions()
  end

  def set_memory(computer, memory) when is_map(memory), do: %{computer | memory: memory}

  def update_memory(computer, values) when is_map(values) do
    %{computer | memory: Map.merge(computer.memory, values)}
  end

  def get_memory(%{memory: memory} = _computer, address), do: Map.fetch!(memory, address)

  defp run_instructions(%{pc: pc, memory: memory} = computer) do
    case Map.fetch!(memory, pc) do
      99 ->
        computer

      instruction ->
        new_computer =
          computer
          |> run_instruction(instruction)

        run_instructions(%{new_computer | pc: new_computer.pc + 4})
    end
  end

  defp run_instruction(computer, 1) do
    computer
    |> calculate_value(&+/2)
    |> save_value()
  end

  defp run_instruction(computer, 2) do
    computer
    |> calculate_value(&*/2)
    |> save_value()
  end

  defp calculate_value(computer, fun) do
    {operand1, operand2} = get_operands(computer)

    %{computer | value: fun.(operand1, operand2)}
  end

  defp save_value(computer) do
    result_address = get_result_address(computer)
    %{computer | memory: Map.put(computer.memory, result_address, computer.value)}
  end

  defp get_operands(%{pc: pc, memory: memory} = _computer) do
    operand1_addr = Map.fetch!(memory, pc + 1)
    operand2_addr = Map.fetch!(memory, pc + 2)

    {Map.fetch!(memory, operand1_addr), Map.fetch!(memory, operand2_addr)}
  end

  defp get_result_address(%{pc: pc, memory: memory} = _computer), do: Map.fetch!(memory, pc + 3)
end

computer = IntcodeComputer.new("day2.txt")
expected_result = 19_690_720

computer
|> IntcodeComputer.update_memory(%{1 => 12, 2 => 2})
|> IntcodeComputer.run()
|> IntcodeComputer.get_memory(0)
|> IO.inspect(label: "Part 1")

for(x <- 0..99, y <- 0..99, do: %{1 => x, 2 => y})
|> Enum.reduce_while(computer, fn input_memory, computer ->
  result =
    computer
    |> IntcodeComputer.update_memory(input_memory)
    |> IntcodeComputer.run()
    |> IntcodeComputer.get_memory(0)

  if result == expected_result do
    {:halt, input_memory}
  else
    {:cont, computer}
  end
end)
|> (fn %{1 => noun, 2 => verb} -> 100 * noun + verb end).()
|> IO.inspect(label: "Part 2")
