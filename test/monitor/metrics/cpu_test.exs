defmodule Monitor.Metrics.CPUTest do
  use ExUnit.Case, async: true

  alias Monitor.Metrics.CPU

  describe "collect/0" do
    test "returns valid CPU metrics structure" do
      result = CPU.collect()

      assert is_map(result)
      assert Map.has_key?(result, :overall_usage)
      assert Map.has_key?(result, :load_average)
      assert Map.has_key?(result, :per_core)
      assert Map.has_key?(result, :core_count)
    end

    test "load average has required keys" do
      result = CPU.collect()

      assert Map.has_key?(result.load_average, :one_min)
      assert Map.has_key?(result.load_average, :five_min)
      assert Map.has_key?(result.load_average, :fifteen_min)
    end

    test "overall usage is a non-negative integer" do
      result = CPU.collect()

      assert is_integer(result.overall_usage)
      assert result.overall_usage >= 0
      assert result.overall_usage <= 100
    end

    test "core count is a positive integer" do
      result = CPU.collect()

      assert is_integer(result.core_count)
      assert result.core_count > 0
    end

    test "per core is a list" do
      result = CPU.collect()

      assert is_list(result.per_core)
    end

    test "per core entries have required keys when not empty" do
      result = CPU.collect()

      if length(result.per_core) > 0 do
        core = Enum.at(result.per_core, 0)
        assert Map.has_key?(core, :core)
        assert Map.has_key?(core, :usage)
      end
    end
  end
end
