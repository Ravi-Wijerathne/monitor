defmodule Monitor.SystemMonitor do
  use GenServer

  alias Monitor.Metrics.{CPU, Memory, Disk, Network, Processes, System, GPU}

  @update_interval 1000
  @topic "system_metrics"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_current_metrics do
    case GenServer.whereis(__MODULE__) do
      nil ->
        default_metrics()
      pid ->
        try do
          GenServer.call(pid, :get_metrics, 5000)
        catch
          :exit, _ -> default_metrics()
        end
    end
  end

  @impl true
  def init(_state) do
    Process.flag(:trap_exit, true)
    state = safe_collect_metrics()
    schedule_collection()
    {:ok, state}
  end

  @impl true
  def handle_info(:collect, state) do
    new_state = safe_collect_metrics()
    new_state = calculate_network_speed(new_state, state)

    Phoenix.PubSub.broadcast(
      Monitor.PubSub,
      @topic,
      {:metrics_update, new_state}
    )

    schedule_collection()
    {:noreply, new_state}
  end

  @impl true
  def handle_info({:EXIT, _pid, reason}, state) do
    IO.puts("SystemMonitor received EXIT: #{inspect(reason)}")
    {:noreply, state}
  end

  @impl true
  def handle_info({_port, :closed}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) when is_tuple(msg) do
    {:noreply, state}
  end

  @impl true
  def handle_call(:get_metrics, _from, state) do
    {:reply, state, state}
  end

  defp schedule_collection do
    Process.send_after(self(), :collect, @update_interval)
  end

  defp safe_collect_metrics do
    try do
      %{
        timestamp: DateTime.utc_now(),
        cpu: CPU.collect(),
        memory: Memory.collect(),
        disk: Disk.collect(),
        network: Network.collect(),
        processes: Processes.collect(15),
        system: System.collect(),
        gpu: GPU.collect()
      }
    rescue
      _ ->
        default_metrics()
    end
  end

  defp calculate_network_speed(current_metrics, previous_state) do
    if Map.has_key?(previous_state, :network) && Map.has_key?(previous_state, :timestamp) do
      prev_network = previous_state.network
      curr_network = current_metrics.network
      time_diff = DateTime.diff(current_metrics.timestamp, previous_state.timestamp)

      if time_diff > 0 do
        download_diff = curr_network.total_download_mb - prev_network.total_download_mb
        upload_diff = curr_network.total_upload_mb - prev_network.total_upload_mb

        download_speed = Float.round(download_diff / time_diff, 2)
        upload_speed = Float.round(upload_diff / time_diff, 2)

        network_with_speed = Map.merge(curr_network, %{
          download_speed_mbps: max(0, download_speed),
          upload_speed_mbps: max(0, upload_speed)
        })

        Map.put(current_metrics, :network, network_with_speed)
      else
        current_metrics
      end
    else
      current_metrics
    end
  end

  defp default_metrics do
    %{
      timestamp: DateTime.utc_now(),
      cpu: %{overall_usage: 0, core_count: 0, load_average: %{one_min: 0, five_min: 0, fifteen_min: 0}, per_core: []},
      memory: %{total: 0, used: 0, free: 0, percent_used: 0, swap: %{total: 0, used: 0, free: 0, percent_used: 0}},
      disk: [],
      network: %{interfaces: [], total_download_mb: 0, total_upload_mb: 0, download_speed_mbps: 0, upload_speed_mbps: 0},
      processes: [],
      system: %{hostname: "", os_type: "Windows", uptime: "", kernel_version: ""},
      gpu: []
    }
  end
end
