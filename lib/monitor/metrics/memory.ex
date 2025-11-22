defmodule Monitor.Metrics.Memory do
  @moduledoc """
  Collects memory metrics using Erlang's :memsup module
  """

  def collect do
    system_mem = get_system_memory()
    swap = get_swap_memory()

    %{
      total: system_mem.total,
      used: system_mem.used,
      free: system_mem.free,
      percent_used: system_mem.percent_used,
      swap: swap
    }
  end

  defp get_system_memory do
    try do
      data = :memsup.get_system_memory_data()

      total = Keyword.get(data, :total_memory, 0)
      free = Keyword.get(data, :free_memory, 0)
      available = Keyword.get(data, :available_memory, free)
      
      used = total - available
      percent_used = if total > 0, do: round(used / total * 100), else: 0

      %{
        total: bytes_to_mb(total),
        free: bytes_to_mb(available),
        used: bytes_to_mb(used),
        percent_used: percent_used
      }
    rescue
      _ ->
        %{total: 0, free: 0, used: 0, percent_used: 0}
    end
  end

  defp get_swap_memory do
    try do
      data = :memsup.get_system_memory_data()
      
      total_swap = Keyword.get(data, :total_swap, 0)
      free_swap = Keyword.get(data, :free_swap, 0)
      
      used_swap = total_swap - free_swap
      percent_used = if total_swap > 0, do: round(used_swap / total_swap * 100), else: 0

      %{
        total: bytes_to_mb(total_swap),
        free: bytes_to_mb(free_swap),
        used: bytes_to_mb(used_swap),
        percent_used: percent_used
      }
    rescue
      _ ->
        %{total: 0, free: 0, used: 0, percent_used: 0}
    end
  end

  defp bytes_to_mb(bytes), do: Float.round(bytes / 1024 / 1024, 2)
end
