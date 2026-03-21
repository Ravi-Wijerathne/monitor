defmodule Monitor.Metrics.SystemTest do
  use ExUnit.Case, async: true

  alias Monitor.Metrics.System

  describe "collect/0" do
    test "returns valid system metrics structure" do
      result = System.collect()

      assert is_map(result)
      assert Map.has_key?(result, :hostname)
      assert Map.has_key?(result, :os_type)
      assert Map.has_key?(result, :uptime)
      assert Map.has_key?(result, :kernel_version)
      assert Map.has_key?(result, :architecture)
    end

    test "hostname is a string" do
      result = System.collect()

      assert is_binary(result.hostname)
      assert byte_size(result.hostname) > 0
    end

    test "os_type is a string" do
      result = System.collect()

      assert is_binary(result.os_type)
      assert byte_size(result.os_type) > 0
    end

    test "uptime is formatted correctly" do
      result = System.collect()

      assert is_binary(result.uptime)
      assert byte_size(result.uptime) > 0
    end

    test "kernel_version is a string" do
      result = System.collect()

      assert is_binary(result.kernel_version)
    end

    test "architecture is a string" do
      result = System.collect()

      assert is_binary(result.architecture)
      assert byte_size(result.architecture) > 0
    end

    test "os_type is one of the expected values" do
      result = System.collect()

      valid_os_types = ["Linux", "macOS", "FreeBSD", "Windows"]
      assert result.os_type in valid_os_types or result.os_type =~ ~r/\w+\/\w+/
    end
  end
end
