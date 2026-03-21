defmodule Monitor.Metrics.MemoryTest do
  use ExUnit.Case, async: true

  alias Monitor.Metrics.Memory

  describe "collect/0" do
    test "returns valid memory metrics structure" do
      result = Memory.collect()

      assert is_map(result)
      assert Map.has_key?(result, :total)
      assert Map.has_key?(result, :used)
      assert Map.has_key?(result, :free)
      assert Map.has_key?(result, :percent_used)
      assert Map.has_key?(result, :swap)
    end

    test "swap has required keys" do
      result = Memory.collect()

      assert Map.has_key?(result.swap, :total)
      assert Map.has_key?(result.swap, :used)
      assert Map.has_key?(result.swap, :free)
      assert Map.has_key?(result.swap, :percent_used)
    end

    test "values are non-negative" do
      result = Memory.collect()

      assert result.total >= 0
      assert result.used >= 0
      assert result.free >= 0
      assert result.percent_used >= 0
      assert result.percent_used <= 100
    end

    test "total equals used plus free approximately" do
      result = Memory.collect()

      assert_in_delta result.total, result.used + result.free, 1.0
    end

    test "percent used matches actual calculation" do
      result = Memory.collect()

      if result.total > 0 do
        expected_percent = round(result.used / result.total * 100)
        assert result.percent_used == expected_percent
      end
    end

    test "swap percentage is within valid range" do
      result = Memory.collect()

      assert result.swap.percent_used >= 0
      assert result.swap.percent_used <= 100
    end
  end
end
