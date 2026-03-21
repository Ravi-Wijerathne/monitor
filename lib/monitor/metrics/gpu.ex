defmodule Monitor.Metrics.GPU do
  def collect do
    case :os.type() do
      {:unix, _} -> collect_unix()
      {:win32, _} -> collect_windows()
    end
  end

  defp collect_windows do
    nvidia_stats = get_nvidia_stats_windows()

    if nvidia_stats != [] do
      nvidia_stats
    else
      []
    end
  end

  defp collect_unix do
    nvidia_stats = get_nvidia_stats_unix()

    if nvidia_stats != [] do
      nvidia_stats
    else
      []
    end
  end

  defp get_nvidia_stats_windows do
    try do
      cmd = ~c"nvidia-smi --query-gpu=index,name,utilization.gpu,utilization.memory,memory.total,memory.used,memory.free,temperature.gpu,power.draw,power.limit --format=csv,noheader,nounits"
      output = run_cmd(cmd, 3000)

      if String.contains?(output, "not found") or String.trim(output) == "" do
        []
      else
        parse_nvidia_output(output)
      end
    rescue
      _ -> []
    end
  end

  defp get_nvidia_stats_unix do
    try do
      cmd = ~c"nvidia-smi --query-gpu=index,name,utilization.gpu,utilization.memory,memory.total,memory.used,memory.free,temperature.gpu,power.draw,power.limit --format=csv,noheader,nounits"
      output = run_cmd(cmd, 3000)

      if String.contains?(output, "not found") or String.trim(output) == "" do
        []
      else
        parse_nvidia_output(output)
      end
    rescue
      _ -> []
    end
  end

  defp run_cmd(cmd, timeout) do
    task = Task.async(fn -> :os.cmd(cmd) |> to_string() end)
    Task.yield(task, timeout) || ""
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
