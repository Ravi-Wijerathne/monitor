defmodule Monitor.Metrics.DiskTest do
  use ExUnit.Case, async: true

  alias Monitor.Metrics.Disk

  describe "collect/0" do
    test "returns a list" do
      result = Disk.collect()

      assert is_list(result)
    end

    test "each disk entry has required keys" do
      result = Disk.collect()

      if length(result) > 0 do
        disk = Enum.at(result, 0)
        assert Map.has_key?(disk, :mount_point)
        assert Map.has_key?(disk, :total)
        assert Map.has_key?(disk, :used)
        assert Map.has_key?(disk, :free)
        assert Map.has_key?(disk, :percent_used)
      end
    end

    test "disk values are non-negative" do
      result = Disk.collect()

      for disk <- result do
        assert disk.total >= 0
        assert disk.used >= 0
        assert disk.free >= 0
        assert disk.percent_used >= 0
        assert disk.percent_used <= 100
      end
    end

    test "used plus free approximately equals total" do
      result = Disk.collect()

      for disk <- result do
        assert_in_delta disk.total, disk.used + disk.free, 0.1
      end
    end

    test "percent used matches actual calculation" do
      result = Disk.collect()

      for disk <- result do
        if disk.total > 0 do
          expected_percent = disk.used / disk.total * 100
          assert_in_delta disk.percent_used, expected_percent, 1.0
        end
      end
    end

    test "mount point is a string" do
      result = Disk.collect()

      for disk <- result do
        assert is_binary(disk.mount_point)
      end
    end
  end
end
