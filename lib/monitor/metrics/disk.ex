defmodule Monitor.Metrics.Disk do
  def collect do
    case :os.type() do
      {:win32, _} -> get_disk_data_windows()
      {:unix, _} -> get_disk_data_unix()
    end
  end

  defp get_disk_data_unix do
    try do
      :disksup.get_disk_data()
      |> Enum.map(fn {id, kb_size, capacity} ->
        total_gb = kb_size / 1024 / 1024
        used_percent = capacity
        used_gb = total_gb * (used_percent / 100)
        free_gb = total_gb - used_gb

        %{
          mount_point: to_string(id),
          total: Float.round(total_gb, 2),
          used: Float.round(used_gb, 2),
          free: Float.round(free_gb, 2),
          percent_used: used_percent
        }
      end)
    rescue
      _ -> []
    end
  end

  defp get_disk_data_windows do
    try do
      cmd = ~c"powershell -Command \"Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | ForEach-Object {@{Drive=$_.DeviceID;Total=([math]::Round($_.Size/1GB,2));Free=([math]::Round($_.FreeSpace/1GB,2))}} | ConvertTo-Json -Compress\""
      output = :os.cmd(cmd) |> to_string() |> String.trim()

      cond do
        output == "" or output == "null" ->
          []
        String.starts_with?(output, "[") ->
          case Jason.decode(output) do
            {:ok, disks} when is_list(disks) ->
              Enum.map(disks, &parse_disk_windows/1)
            _ ->
              []
          end
        String.starts_with?(output, "{") ->
          case Jason.decode(output) do
            {:ok, disk} ->
              [parse_disk_windows(disk)]
            _ ->
              []
          end
        true ->
          []
      end
    rescue
      _ ->
        []
    end
  end

  defp parse_disk_windows(disk) do
    drive = disk["Drive"] || "C:"
    total = disk["Total"] || 0
    free = disk["Free"] || 0
    used = total - free
    percent_used = if total > 0, do: round(used / total * 100), else: 0

    %{
      mount_point: drive,
      total: total,
      used: Float.round(used, 2),
      free: free,
      percent_used: percent_used
    }
  end
end
