defmodule Monitor.Metrics.ProcessesTest do
  use ExUnit.Case, async: true

  alias Monitor.Metrics.Processes

  describe "collect/1" do
    test "returns a list" do
      result = Processes.collect(15)

      assert is_list(result)
    end

    test "each process has required keys" do
      result = Processes.collect(15)

      if length(result) > 0 do
        process = Enum.at(result, 0)
        assert Map.has_key?(process, :pid)
        assert Map.has_key?(process, :cpu_percent)
        assert Map.has_key?(process, :mem_percent)
        assert Map.has_key?(process, :command)
      end
    end

    test "cpu and memory percentages are non-negative" do
      result = Processes.collect(15)

      for process <- result do
        assert process.cpu_percent >= 0
        assert process.mem_percent >= 0
      end
    end

    test "command is a string" do
      result = Processes.collect(15)

      for process <- result do
        assert is_binary(process.command) or is_atom(process.command)
      end
    end

    test "respects limit parameter" do
      limit = 5
      result = Processes.collect(limit)

      assert length(result) <= limit
    end
  end
end
