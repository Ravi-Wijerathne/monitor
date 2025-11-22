defmodule Monitor.Metrics.CPU do
  @moduledoc """
  Collects CPU metrics using Erlang's :cpu_sup module
  """

  def collect do
    load_avg = get_load_average()
    utilization = get_cpu_utilization()
    per_core = get_per_core_usage()

    %{
      overall_usage: utilization,
      load_average: load_avg,
      per_core: per_core,
      core_count: System.schedulers_online()
    }
  end

  defp get_load_average do
    case :os.type() do
      {:unix, _} ->
        try do
          # Get load average from system
          {load1, load5, load15} = :cpu_sup.avg1() |> parse_load_avg()
          %{one_min: load1, five_min: load5, fifteen_min: load15}
        rescue
          _ ->
            %{one_min: 0.0, five_min: 0.0, fifteen_min: 0.0}
        end

      {:win32, _} ->
        # Windows doesn't have load average
        %{one_min: 0.0, five_min: 0.0, fifteen_min: 0.0}
    end
  end

  defp parse_load_avg(load) when is_integer(load) do
    avg = load / 256
    {avg, avg, avg}
  end

  defp parse_load_avg(_), do: {0.0, 0.0, 0.0}

  defp get_cpu_utilization do
    try do
      case :cpu_sup.util() do
        util when is_number(util) -> round(util)
        {:all, _total, _busy, list} when is_list(list) ->
          # Average across all cores
          total = Enum.reduce(list, 0, fn {_id, busy, _total, _}, acc -> acc + busy end)
          round(total / length(list))
        _ -> 0
      end
    rescue
      _ -> 0
    end
  end

  defp get_per_core_usage do
    try do
      case :cpu_sup.util([:per_cpu]) do
        list when is_list(list) ->
          Enum.map(list, fn
            {id, busy, _total, _} -> %{core: id, usage: round(busy)}
            _ -> %{core: 0, usage: 0}
          end)

        _ ->
          []
      end
    rescue
      _ -> []
    end
  end
end
