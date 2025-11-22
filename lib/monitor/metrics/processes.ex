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
      # Use PowerShell Get-Process for better CPU info on Windows
      # Export as CSV for easier parsing
      cmd = ~c"powershell -Command \"Get-Process | Sort-Object CPU -Descending | Select-Object -First #{limit} ProcessName,Id,CPU,WorkingSet | ConvertTo-Csv -NoTypeInformation\""
      output = :os.cmd(cmd) |> to_string()
      parse_powershell_csv_output(output)
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

  defp parse_powershell_csv_output(output) do
    lines = String.split(output, ["\r\n", "\n"], trim: true)
    
    # Skip header line
    lines
    |> Enum.drop(1)
    |> Enum.map(fn line ->
      # Remove quotes and split by comma
      parts = 
        line
        |> String.replace("\"", "")
        |> String.split(",")
      
      if length(parts) >= 4 do
        process_name = Enum.at(parts, 0) |> String.trim()
        pid = Enum.at(parts, 1) |> String.trim()
        cpu_str = Enum.at(parts, 2) |> String.trim()
        mem_str = Enum.at(parts, 3) |> String.trim()
        
        cpu = parse_float(cpu_str)
        mem_bytes = parse_integer(mem_str)
        
        # Convert to percentage (based on total memory from Memory collector)
        mem_mb = mem_bytes / (1024 * 1024)
        mem_percent = (mem_mb / 16085.52) * 100
        
        %{
          user: "N/A",
          pid: pid,
          cpu_percent: Float.round(cpu, 1),
          mem_percent: Float.round(mem_percent, 1),
          vsz: "N/A",
          rss: "#{round(mem_mb)} MB",
          tty: "N/A",
          stat: "Running",
          start: "N/A",
          time: "N/A",
          command: process_name
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

  defp parse_integer(str) do
    case Integer.parse(str) do
      {int, _} -> int
      :error -> 0
    end
  end
end
