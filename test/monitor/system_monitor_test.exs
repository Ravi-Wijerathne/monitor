defmodule Monitor.SystemMonitorTest do
  use ExUnit.Case, async: false

  alias Monitor.SystemMonitor

  setup do
    case Process.whereis(Monitor.SystemMonitor) do
      nil -> start_supervised!(Monitor.SystemMonitor)
      _pid -> :ok
    end
    :ok
  end

  describe "start_link/1" do
    test "starts the GenServer successfully" do
      pid = Process.whereis(Monitor.SystemMonitor)
      assert is_pid(pid)
    end
  end

  describe "get_current_metrics/0" do
    test "returns a map with all required keys" do
      metrics = SystemMonitor.get_current_metrics()

      assert is_map(metrics)
      assert Map.has_key?(metrics, :timestamp)
      assert Map.has_key?(metrics, :cpu)
      assert Map.has_key?(metrics, :memory)
      assert Map.has_key?(metrics, :disk)
      assert Map.has_key?(metrics, :network)
      assert Map.has_key?(metrics, :processes)
      assert Map.has_key?(metrics, :system)
      assert Map.has_key?(metrics, :gpu)
    end

    test "cpu metrics have required keys" do
      metrics = SystemMonitor.get_current_metrics()

      assert Map.has_key?(metrics.cpu, :overall_usage)
      assert Map.has_key?(metrics.cpu, :load_average)
      assert Map.has_key?(metrics.cpu, :core_count)
    end

    test "memory metrics have required keys" do
      metrics = SystemMonitor.get_current_metrics()

      assert Map.has_key?(metrics.memory, :total)
      assert Map.has_key?(metrics.memory, :used)
      assert Map.has_key?(metrics.memory, :percent_used)
    end

    test "network metrics have required keys" do
      metrics = SystemMonitor.get_current_metrics()

      assert Map.has_key?(metrics.network, :total_download_mb)
      assert Map.has_key?(metrics.network, :total_upload_mb)
    end

    test "system metrics have required keys" do
      metrics = SystemMonitor.get_current_metrics()

      assert Map.has_key?(metrics.system, :hostname)
      assert Map.has_key?(metrics.system, :os_type)
      assert Map.has_key?(metrics.system, :uptime)
    end

    test "timestamp is a DateTime" do
      metrics = SystemMonitor.get_current_metrics()

      assert match?(%DateTime{}, metrics.timestamp)
    end
  end
end
