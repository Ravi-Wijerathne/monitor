defmodule Monitor.Metrics.Processes do
  @moduledoc """
  Collects running process information
  """

  def collect(limit \\ 15) do
    case :os.type() do
      {:unix, _} -> collect_unix(limit)
      {:win32, _} -> collect_windows(limit)
    end
  end

  defp collect_unix(limit) do
    try do
      # Use ps command to get process list sorted by CPU usage
      output = :os.cmd('ps aux --sort=-%cpu | head -n #{limit + 1}') |> to_string()
      parse_ps_output(output)
    rescue
      _ -> []
    end
  end

  defp collect_windows(limit) do
    try do
      # Use tasklist for Windows
      output = :os.cmd('tasklist') |> to_string()
      parse_tasklist_output(output, limit)
    rescue
      _ -> []
    end
  end

  defp parse_ps_output(output) do
    lines = String.split(output, "\n")
    
    lines
    |> Enum.drop(1)  # Skip header
    |> Enum.filter(&(String.trim(&1) != ""))
    |> Enum.map(fn line ->
      parts = String.split(line, ~r/\s+/, trim: true)
      
      if length(parts) >= 11 do
        %{
          user: Enum.at(parts, 0),
          pid: Enum.at(parts, 1),
          cpu_percent: parse_float(Enum.at(parts, 2)),
          mem_percent: parse_float(Enum.at(parts, 3)),
          vsz: Enum.at(parts, 4),
          rss: Enum.at(parts, 5),
          tty: Enum.at(parts, 6),
          stat: Enum.at(parts, 7),
          start: Enum.at(parts, 8),
          time: Enum.at(parts, 9),
          command: Enum.drop(parts, 10) |> Enum.join(" ")
        }
      else
        nil
      end
    end)
    |> Enum.filter(& &1)
  end

  defp parse_tasklist_output(output, limit) do
    lines = String.split(output, "\n")
    
    lines
    |> Enum.drop(3)  # Skip header lines
    |> Enum.take(limit)
    |> Enum.filter(&(String.trim(&1) != ""))
    |> Enum.map(fn line ->
      parts = String.split(line, ~r/\s+/, trim: true)
      
      if length(parts) >= 5 do
        %{
          user: "N/A",
          pid: Enum.at(parts, 1),
          cpu_percent: 0.0,
          mem_percent: 0.0,
          vsz: "N/A",
          rss: parse_memory(Enum.at(parts, 4)),
          tty: "N/A",
          stat: Enum.at(parts, 3),
          start: "N/A",
          time: "N/A",
          command: Enum.at(parts, 0)
        }
      else
        nil
      end
    end)
    |> Enum.filter(& &1)
  end

  defp parse_float(str) do
    case Float.parse(str) do
      {float, _} -> float
      :error -> 0.0
    end
  end

  defp parse_memory(str) do
    str
    |> String.replace(",", "")
    |> String.replace("K", "")
    |> String.trim()
  end
end
