defmodule Monitor.Metrics.Disk do
  @moduledoc """
  Collects disk usage metrics using Erlang's :disksup module
  """

  def collect do
    get_disk_data()
  end

  defp get_disk_data do
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
end
