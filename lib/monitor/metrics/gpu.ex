defmodule Monitor.Metrics.GPU do
  @moduledoc """
  Collects GPU metrics using various methods depending on the platform and GPU vendor
  """

  def collect do
    case :os.type() do
      {:unix, _} -> collect_unix()
      {:win32, _} -> collect_windows()
    end
  end

  defp collect_windows do
    # Try NVIDIA first, then AMD, then Intel
    nvidia_stats = get_nvidia_stats_windows()

    if nvidia_stats != [] do
      nvidia_stats
    else
      amd_stats = get_amd_stats_windows()
      if amd_stats != [] do
        amd_stats
      else
        get_intel_stats_windows()
      end
    end
  end

  defp collect_unix do
    # Try nvidia-smi on Unix systems
    nvidia_stats = get_nvidia_stats_unix()

    if nvidia_stats != [] do
      nvidia_stats
    else
      []
    end
  end

  # NVIDIA GPU monitoring (Windows)
  defp get_nvidia_stats_windows do
    try do
      # Use nvidia-smi if available
      cmd = ~c"nvidia-smi --query-gpu=index,name,utilization.gpu,utilization.memory,memory.total,memory.used,memory.free,temperature.gpu,power.draw,power.limit --format=csv,noheader,nounits"
      output = :os.cmd(cmd) |> to_string()

      if String.contains?(output, "not found") or String.trim(output) == "" do
        []
      else
        parse_nvidia_output(output)
      end
    rescue
      _ -> []
    end
  end

  # NVIDIA GPU monitoring (Unix)
  defp get_nvidia_stats_unix do
    try do
      cmd = ~c"nvidia-smi --query-gpu=index,name,utilization.gpu,utilization.memory,memory.total,memory.used,memory.free,temperature.gpu,power.draw,power.limit --format=csv,noheader,nounits"
      output = :os.cmd(cmd) |> to_string()

      if String.contains?(output, "not found") or String.trim(output) == "" do
        []
      else
        parse_nvidia_output(output)
      end
    rescue
      _ -> []
    end
  end

  defp parse_nvidia_output(output) do
    lines = String.split(output, ["\r\n", "\n"], trim: true)

    Enum.map(lines, fn line ->
      parts = String.split(line, ",") |> Enum.map(&String.trim/1)

      if length(parts) >= 10 do
        %{
          vendor: "NVIDIA",
          index: Enum.at(parts, 0),
          name: Enum.at(parts, 1),
          gpu_usage: parse_integer(Enum.at(parts, 2)),
          memory_usage: parse_integer(Enum.at(parts, 3)),
          memory_total: parse_integer(Enum.at(parts, 4)),
          memory_used: parse_integer(Enum.at(parts, 5)),
          memory_free: parse_integer(Enum.at(parts, 6)),
          temperature: parse_integer(Enum.at(parts, 7)),
          power_draw: parse_float(Enum.at(parts, 8)),
          power_limit: parse_float(Enum.at(parts, 9))
        }
      else
        nil
      end
    end)
    |> Enum.filter(& &1)
  end

  # AMD GPU monitoring (Windows) - using PowerShell and WMI
  defp get_amd_stats_windows do
    try do
      # Use PowerShell to query GPU info
      cmd = ~c"powershell -Command \"Get-WmiObject Win32_VideoController | Where-Object {$_.Name -like '*AMD*' -or $_.Name -like '*Radeon*'} | Select-Object Name,AdapterRAM,CurrentHorizontalResolution,CurrentVerticalResolution | ConvertTo-Csv -NoTypeInformation\""
      output = :os.cmd(cmd) |> to_string()

      if String.trim(output) == "" or String.contains?(output, "error") do
        []
      else
        parse_amd_output(output)
      end
    rescue
      _ -> []
    end
  end

  defp parse_amd_output(output) do
    lines = String.split(output, ["\r\n", "\n"], trim: true)

    # Skip header
    lines
    |> Enum.drop(1)
    |> Enum.map(fn line ->
      parts =
        line
        |> String.replace("\"", "")
        |> String.split(",")

      if length(parts) >= 2 do
        name = Enum.at(parts, 0) |> String.trim()
        memory_bytes = parse_integer(Enum.at(parts, 1))
        memory_mb = div(memory_bytes, 1024 * 1024)

        %{
          vendor: "AMD",
          index: "0",
          name: name,
          gpu_usage: 0,  # WMI doesn't provide real-time usage
          memory_usage: 0,
          memory_total: memory_mb,
          memory_used: 0,
          memory_free: memory_mb,
          temperature: 0,
          power_draw: 0.0,
          power_limit: 0.0
        }
      else
        nil
      end
    end)
    |> Enum.filter(& &1)
  end

  # Intel GPU monitoring (Windows) - basic info
  defp get_intel_stats_windows do
    try do
      cmd = ~c"powershell -Command \"Get-WmiObject Win32_VideoController | Where-Object {$_.Name -like '*Intel*'} | Select-Object Name,AdapterRAM | ConvertTo-Csv -NoTypeInformation\""
      output = :os.cmd(cmd) |> to_string()

      if String.trim(output) == "" or String.contains?(output, "error") do
        []
      else
        parse_intel_output(output)
      end
    rescue
      _ -> []
    end
  end

  defp parse_intel_output(output) do
    lines = String.split(output, ["\r\n", "\n"], trim: true)

    # Skip header
    lines
    |> Enum.drop(1)
    |> Enum.map(fn line ->
      parts =
        line
        |> String.replace("\"", "")
        |> String.split(",")

      if length(parts) >= 2 do
        name = Enum.at(parts, 0) |> String.trim()
        memory_bytes = parse_integer(Enum.at(parts, 1))
        memory_mb = div(memory_bytes, 1024 * 1024)

        %{
          vendor: "Intel",
          index: "0",
          name: name,
          gpu_usage: 0,
          memory_usage: 0,
          memory_total: memory_mb,
          memory_used: 0,
          memory_free: memory_mb,
          temperature: 0,
          power_draw: 0.0,
          power_limit: 0.0
        }
      else
        nil
      end
    end)
    |> Enum.filter(& &1)
  end

  defp parse_integer(str) do
    case Integer.parse(String.trim(str)) do
      {int, _} -> int
      :error -> 0
    end
  end

  defp parse_float(str) do
    cleaned = String.trim(str) |> String.replace("[N/A]", "0") |> String.replace("N/A", "0")

    case Float.parse(cleaned) do
      {float, _} -> float
      :error -> 0.0
    end
  end
end
