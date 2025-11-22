defmodule Monitor.Metrics.Network do
  @moduledoc """
  Collects network statistics
  """

  def collect do
    case :os.type() do
      {:unix, _} -> collect_unix()
      {:win32, _} -> collect_windows()
    end
  end

  defp collect_unix do
    try do
      output = :os.cmd('cat /proc/net/dev 2>/dev/null') |> to_string()
      parse_proc_net_dev(output)
    rescue
      _ -> default_network_stats()
    end
  end

  defp collect_windows do
    try do
      # Use cmd /c to ensure netstat runs properly
      output = :os.cmd(~c"cmd /c netstat -e") |> to_string()
      parse_netstat(output)
    rescue
      _ -> default_network_stats()
    end
  end

  defp parse_proc_net_dev(output) do
    lines = String.split(output, "\n")
    
    interfaces = 
      lines
      |> Enum.drop(2)  # Skip header lines
      |> Enum.filter(&String.contains?(&1, ":"))
      |> Enum.map(fn line ->
        [interface | stats] = String.split(line, ~r/[:\s]+/, trim: true)
        stats = Enum.map(stats, &String.to_integer/1)
        
        rx_bytes = Enum.at(stats, 0, 0)
        tx_bytes = Enum.at(stats, 8, 0)
        
        %{
          interface: interface,
          rx_bytes: rx_bytes,
          tx_bytes: tx_bytes,
          rx_mb: bytes_to_mb(rx_bytes),
          tx_mb: bytes_to_mb(tx_bytes)
        }
      end)

    total_rx = Enum.sum(Enum.map(interfaces, & &1.rx_bytes))
    total_tx = Enum.sum(Enum.map(interfaces, & &1.tx_bytes))

    %{
      interfaces: interfaces,
      total_download_mb: bytes_to_mb(total_rx),
      total_upload_mb: bytes_to_mb(total_tx),
      download_speed_mbps: 0.0,  # Will be calculated by comparing with previous values
      upload_speed_mbps: 0.0
    }
  rescue
    _ -> default_network_stats()
  end

  defp parse_netstat(output) do
    try do
      # Parse Windows netstat -e output
      lines = String.split(output, ["\r\n", "\n"], trim: true)
      
      # Find the data line (after "Bytes" header)
      bytes_index = Enum.find_index(lines, &String.contains?(&1, "Bytes"))
      
      if bytes_index && bytes_index + 1 < length(lines) do
        data_line = Enum.at(lines, bytes_index + 1)
        
        # Split by whitespace and extract numbers
        numbers = 
          data_line
          |> String.split(~r/\s+/, trim: true)
          |> Enum.map(fn str ->
            # Remove commas and parse
            String.replace(str, ",", "")
            |> Integer.parse()
            |> case do
              {num, _} -> num
              :error -> 0
            end
          end)
        
        rx = Enum.at(numbers, 0, 0)
        tx = Enum.at(numbers, 1, 0)
        
        %{
          interfaces: [],
          total_download_mb: bytes_to_mb(rx),
          total_upload_mb: bytes_to_mb(tx),
          download_speed_mbps: 0.0,
          upload_speed_mbps: 0.0
        }
      else
        default_network_stats()
      end
    rescue
      _ -> default_network_stats()
    end
  end

  defp default_network_stats do
    %{
      interfaces: [],
      total_download_mb: 0.0,
      total_upload_mb: 0.0,
      download_speed_mbps: 0.0,
      upload_speed_mbps: 0.0
    }
  end

  defp bytes_to_mb(bytes), do: Float.round(bytes / 1024 / 1024, 2)
end
