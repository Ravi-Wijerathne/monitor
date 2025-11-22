defmodule Monitor.Metrics.System do
  @moduledoc """
  Collects general system information
  """

  def collect do
    %{
      hostname: get_hostname(),
      os_type: get_os_type(),
      uptime: get_uptime(),
      kernel_version: get_kernel_version(),
      architecture: get_architecture()
    }
  end

  defp get_hostname do
    case :inet.gethostname() do
      {:ok, hostname} -> to_string(hostname)
      _ -> "Unknown"
    end
  end

  defp get_os_type do
    case :os.type() do
      {:unix, :linux} -> "Linux"
      {:unix, :darwin} -> "macOS"
      {:unix, :freebsd} -> "FreeBSD"
      {:win32, :nt} -> "Windows"
      {family, name} -> "#{family}/#{name}"
    end
  end

  defp get_uptime do
    {uptime_ms, _} = :erlang.statistics(:wall_clock)
    format_uptime(div(uptime_ms, 1000))
  end

  defp format_uptime(seconds) do
    days = div(seconds, 86400)
    hours = div(rem(seconds, 86400), 3600)
    minutes = div(rem(seconds, 3600), 60)
    secs = rem(seconds, 60)

    cond do
      days > 0 -> "#{days}d #{hours}h #{minutes}m"
      hours > 0 -> "#{hours}h #{minutes}m #{secs}s"
      minutes > 0 -> "#{minutes}m #{secs}s"
      true -> "#{secs}s"
    end
  end

  defp get_kernel_version do
    case :os.type() do
      {:unix, _} ->
        try do
          :os.cmd('uname -r') |> to_string() |> String.trim()
        rescue
          _ -> "Unknown"
        end

      {:win32, _} ->
        try do
          :os.cmd('ver') |> to_string() |> String.trim()
        rescue
          _ -> "Unknown"
        end
    end
  end

  defp get_architecture do
    to_string(:erlang.system_info(:system_architecture))
  end
end
