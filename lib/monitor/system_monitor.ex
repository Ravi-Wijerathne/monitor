defmodule Monitor.SystemMonitor do
  @moduledoc """
  GenServer that collects system metrics and broadcasts them via PubSub.
  Updates every 1 second by default.
  """
  use GenServer

  alias Monitor.Metrics.{CPU, Memory, Disk, Network, Processes, System, GPU}

  @update_interval 1000  # 1 second
  @topic "system_metrics"

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_current_metrics do
    GenServer.call(__MODULE__, :get_metrics)
  end

  # Server Callbacks

  @impl true
  def init(_state) do
    # Start OS monitoring applications
    start_os_mon()

    # Give cpu_sup time to collect baseline measurements (at least 1 second)
    # Without this delay, cpu_sup returns 100% for all cores on first calls
    Process.sleep(1500)

    # Collect initial metrics
    initial_state = collect_all_metrics()

    # Schedule first collection
    schedule_collection()

    {:ok, initial_state}
  end

  @impl true
  def handle_info(:collect, state) do
    metrics = collect_all_metrics()

    # Calculate network speed by comparing with previous state
    metrics = calculate_network_speed(metrics, state)

    # Broadcast to all subscribers
    Phoenix.PubSub.broadcast(
      Monitor.PubSub,
      @topic,
      {:metrics_update, metrics}
    )

    # Schedule next collection
    schedule_collection()

    {:noreply, metrics}
  end

  @impl true
  def handle_call(:get_metrics, _from, state) do
    {:reply, state, state}
  end

  # Private Functions

  defp start_os_mon do
    # Ensure :os_mon application is started for :cpu_sup, :memsup, :disksup
    Application.ensure_all_started(:os_mon)

    # Start individual monitors
    try do
      :cpu_sup.start_link()
    rescue
      _ -> :ok
    end

    try do
      :memsup.start_link()
    rescue
      _ -> :ok
    end

    try do
      :disksup.start_link()
    rescue
      _ -> :ok
    end
  end

  defp collect_all_metrics do
    timestamp = DateTime.utc_now()

    %{
      timestamp: timestamp,
      cpu: CPU.collect(),
      memory: Memory.collect(),
      disk: Disk.collect(),
      network: Network.collect(),
      processes: Processes.collect(15),
      system: System.collect(),
      gpu: GPU.collect()
    }
  end

  defp calculate_network_speed(current_metrics, previous_state) do
    if Map.has_key?(previous_state, :network) && Map.has_key?(previous_state, :timestamp) do
      prev_network = previous_state.network
      curr_network = current_metrics.network

      # Calculate time difference in seconds
      time_diff = DateTime.diff(current_metrics.timestamp, previous_state.timestamp)

      if time_diff > 0 do
        # Calculate speed in MB/s
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

  defp schedule_collection do
    Process.send_after(self(), :collect, @update_interval)
  end
end
