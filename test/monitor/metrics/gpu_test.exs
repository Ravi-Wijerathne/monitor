defmodule Monitor.Metrics.GPUTest do
  use ExUnit.Case, async: true

  alias Monitor.Metrics.GPU

  describe "collect/0" do
    test "returns a list" do
      result = GPU.collect()

      assert is_list(result)
    end

    test "each GPU has required keys when not empty" do
      result = GPU.collect()

      if length(result) > 0 do
        gpu = Enum.at(result, 0)
        assert Map.has_key?(gpu, :vendor)
        assert Map.has_key?(gpu, :name)
        assert Map.has_key?(gpu, :gpu_usage)
        assert Map.has_key?(gpu, :memory_usage)
        assert Map.has_key?(gpu, :memory_total)
      end
    end

    test "GPU metrics are within valid ranges" do
      result = GPU.collect()

      for gpu <- result do
        assert gpu.gpu_usage >= 0
        assert gpu.gpu_usage <= 100
        assert gpu.memory_usage >= 0
        assert gpu.memory_usage <= 100
        assert gpu.memory_total >= 0
      end
    end

    test "temperature is non-negative when available" do
      result = GPU.collect()

      for gpu <- result do
        if gpu.temperature > 0 do
          assert gpu.temperature >= 0
          assert gpu.temperature <= 150
        end
      end
    end

    test "power values are non-negative when available" do
      result = GPU.collect()

      for gpu <- result do
        if gpu.power_draw > 0 do
          assert gpu.power_draw >= 0
        end
        if gpu.power_limit > 0 do
          assert gpu.power_limit >= 0
        end
      end
    end

    test "vendor is a known GPU vendor" do
      result = GPU.collect()

      known_vendors = ["NVIDIA", "AMD", "Intel"]
      for gpu <- result do
        assert gpu.vendor in known_vendors
      end
    end

    test "memory values are consistent" do
      result = GPU.collect()

      for gpu <- result do
        if gpu.memory_total > 0 do
          expected_usage = round(gpu.memory_used / gpu.memory_total * 100)
          assert gpu.memory_usage == expected_usage
        end
      end
    end
  end
end
