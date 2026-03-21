defmodule Monitor.Fixtures do
  @moduledoc """
  Test fixtures providing sample data for metric modules.
  """

  def cpu_metrics do
    %{
      overall_usage: 45,
      load_average: %{one_min: 2.5, five_min: 2.0, fifteen_min: 1.8},
      per_core: [
        %{core: 0, usage: 50},
        %{core: 1, usage: 40},
        %{core: 2, usage: 55},
        %{core: 3, usage: 35}
      ],
      core_count: 4
    }
  end

  def cpu_metrics_zero_usage do
    %{
      overall_usage: 0,
      load_average: %{one_min: 0.0, five_min: 0.0, fifteen_min: 0.0},
      per_core: [
        %{core: 0, usage: 0},
        %{core: 1, usage: 0}
      ],
      core_count: 2
    }
  end

  def cpu_metrics_full_usage do
    %{
      overall_usage: 100,
      load_average: %{one_min: 8.0, five_min: 8.0, fifteen_min: 8.0},
      per_core: [
        %{core: 0, usage: 100},
        %{core: 1, usage: 100}
      ],
      core_count: 2
    }
  end

  def memory_metrics do
    %{
      total: 16384.0,
      used: 8192.0,
      free: 8192.0,
      percent_used: 50,
      swap: %{
        total: 8192.0,
        used: 1024.0,
        free: 7168.0,
        percent_used: 12
      }
    }
  end

  def memory_metrics_full do
    %{
      total: 8192.0,
      used: 8192.0,
      free: 0.0,
      percent_used: 100,
      swap: %{
        total: 4096.0,
        used: 4096.0,
        free: 0.0,
        percent_used: 100
      }
    }
  end

  def memory_metrics_zero_swap do
    %{
      total: 16384.0,
      used: 4096.0,
      free: 12288.0,
      percent_used: 25,
      swap: %{
        total: 0.0,
        used: 0.0,
        free: 0.0,
        percent_used: 0
      }
    }
  end

  def disk_metrics do
    [
      %{
        mount_point: "/",
        total: 500.0,
        used: 250.0,
        free: 250.0,
        percent_used: 50
      },
      %{
        mount_point: "/home",
        total: 1000.0,
        used: 750.0,
        free: 250.0,
        percent_used: 75
      }
    ]
  end

  def disk_metrics_full do
    [
      %{
        mount_point: "/",
        total: 100.0,
        used: 95.0,
        free: 5.0,
        percent_used: 95
      }
    ]
  end

  def disk_metrics_critical do
    [
      %{
        mount_point: "/",
        total: 256.0,
        used: 245.0,
        free: 11.0,
        percent_used: 96
      }
    ]
  end

  def network_metrics do
    %{
      interfaces: [
        %{interface: "eth0", rx_bytes: 1_000_000, tx_bytes: 500_000, rx_mb: 0.95, tx_mb: 0.48},
        %{interface: "lo", rx_bytes: 1000, tx_bytes: 1000, rx_mb: 0.001, tx_mb: 0.001}
      ],
      total_download_mb: 100.0,
      total_upload_mb: 50.0,
      download_speed_mbps: 5.5,
      upload_speed_mbps: 2.5
    }
  end

  def network_metrics_empty_interfaces do
    %{
      interfaces: [],
      total_download_mb: 0.0,
      total_upload_mb: 0.0,
      download_speed_mbps: 0.0,
      upload_speed_mbps: 0.0
    }
  end

  def process_metrics do
    [
      %{
        user: "root",
        pid: "1234",
        cpu_percent: 25.5,
        mem_percent: 10.2,
        vsz: "1024000",
        rss: "512000",
        tty: "pts/0",
        stat: "R",
        start: "10:00",
        time: "01:30:00",
        command: "python3 script.py"
      },
      %{
        user: "user",
        pid: "5678",
        cpu_percent: 15.0,
        mem_percent: 5.5,
        vsz: "512000",
        rss: "256000",
        tty: "pts/1",
        stat: "S",
        start: "09:30",
        time: "00:45:00",
        command: "node server.js"
      }
    ]
  end

  def system_metrics do
    %{
      hostname: "test-host",
      os_type: "Linux",
      uptime: "2h 30m 15s",
      kernel_version: "5.4.0-generic",
      architecture: "x86_64"
    }
  end

  def gpu_metrics do
    [
      %{
        vendor: "NVIDIA",
        index: "0",
        name: "GeForce RTX 3080",
        gpu_usage: 75,
        memory_usage: 60,
        memory_total: 10240,
        memory_used: 6144,
        memory_free: 4096,
        temperature: 65,
        power_draw: 250.5,
        power_limit: 320.0
      }
    ]
  end

  def gpu_metrics_multiple do
    [
      %{
        vendor: "NVIDIA",
        index: "0",
        name: "GeForce RTX 3080",
        gpu_usage: 50,
        memory_usage: 40,
        memory_total: 10240,
        memory_used: 4096,
        memory_free: 6144,
        temperature: 55,
        power_draw: 180.0,
        power_limit: 320.0
      },
      %{
        vendor: "NVIDIA",
        index: "1",
        name: "GeForce RTX 3070",
        gpu_usage: 30,
        memory_usage: 25,
        memory_total: 8192,
        memory_used: 2048,
        memory_free: 6144,
        temperature: 50,
        power_draw: 120.0,
        power_limit: 220.0
      }
    ]
  end

  def gpu_metrics_empty do
    []
  end

  def full_metrics do
    %{
      timestamp: DateTime.utc_now(),
      cpu: cpu_metrics(),
      memory: memory_metrics(),
      disk: disk_metrics(),
      network: network_metrics(),
      processes: process_metrics(),
      system: system_metrics(),
      gpu: gpu_metrics()
    }
  end
end
