defmodule MonitorWeb.DashboardLive do
  use MonitorWeb, :live_view

  @topic "system_metrics"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Monitor.PubSub, @topic)
    end

    # Get initial metrics
    initial_metrics = Monitor.SystemMonitor.get_current_metrics()

    {:ok, assign(socket, metrics: initial_metrics)}
  end

  @impl true
  def handle_info({:metrics_update, metrics}, socket) do
    {:noreply, assign(socket, metrics: metrics)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-900 text-white p-6">
      <div class="max-w-7xl mx-auto">
        <!-- Header -->
        <div class="mb-8">
          <h1 class="text-4xl font-bold mb-2">System Monitor Dashboard</h1>
          <p class="text-gray-400">Real-time system resource monitoring</p>
        </div>

        <!-- System Info Bar -->
        <div class="bg-gray-800 rounded-lg p-4 mb-6">
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div>
              <span class="text-gray-400 text-sm">Hostname</span>
              <p class="font-semibold"><%= @metrics.system.hostname %></p>
            </div>
            <div>
              <span class="text-gray-400 text-sm">OS</span>
              <p class="font-semibold"><%= @metrics.system.os_type %></p>
            </div>
            <div>
              <span class="text-gray-400 text-sm">Uptime</span>
              <p class="font-semibold"><%= @metrics.system.uptime %></p>
            </div>
            <div>
              <span class="text-gray-400 text-sm">Kernel</span>
              <p class="font-semibold text-xs"><%= @metrics.system.kernel_version %></p>
            </div>
          </div>
        </div>

        <!-- Main Metrics Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-6">
          <!-- CPU Usage -->
          <.metric_card title="CPU Usage" icon="🔥">
            <div class="space-y-4">
              <div>
                <div class="flex justify-between mb-2">
                  <span class="text-sm">Overall</span>
                  <span class="text-2xl font-bold text-blue-400"><%= @metrics.cpu.overall_usage %>%</span>
                </div>
                <.progress_bar value={@metrics.cpu.overall_usage} color="bg-blue-500" />
              </div>

              <div class="text-xs space-y-1">
                <div class="flex justify-between">
                  <span class="text-gray-400">Cores:</span>
                  <span><%= @metrics.cpu.core_count %></span>
                </div>
                <div class="flex justify-between">
                  <span class="text-gray-400">Load Avg (1m):</span>
                  <span><%= Float.round(@metrics.cpu.load_average.one_min, 2) %></span>
                </div>
                <div class="flex justify-between">
                  <span class="text-gray-400">Load Avg (5m):</span>
                  <span><%= Float.round(@metrics.cpu.load_average.five_min, 2) %></span>
                </div>
              </div>

              <!-- Per Core Usage -->
              <%= if length(@metrics.cpu.per_core) > 0 do %>
                <div class="space-y-1 mt-4">
                  <p class="text-xs text-gray-400 mb-2">Per Core Usage:</p>
                  <%= for core <- Enum.take(@metrics.cpu.per_core, 8) do %>
                    <div class="flex items-center gap-2">
                      <span class="text-xs w-12 text-gray-400">Core <%= core.core %></span>
                      <div class="flex-1">
                        <.progress_bar value={core.usage} color="bg-blue-400" size="sm" />
                      </div>
                      <span class="text-xs w-10 text-right"><%= core.usage %>%</span>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>
          </.metric_card>

          <!-- Memory Usage -->
          <.metric_card title="Memory Usage" icon="💾">
            <div class="space-y-4">
              <div>
                <div class="flex justify-between mb-2">
                  <span class="text-sm">RAM</span>
                  <span class="text-2xl font-bold text-green-400"><%= @metrics.memory.percent_used %>%</span>
                </div>
                <.progress_bar value={@metrics.memory.percent_used} color="bg-green-500" />
              </div>

              <div class="text-xs space-y-1">
                <div class="flex justify-between">
                  <span class="text-gray-400">Total:</span>
                  <span><%= @metrics.memory.total %> MB</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-gray-400">Used:</span>
                  <span><%= @metrics.memory.used %> MB</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-gray-400">Free:</span>
                  <span><%= @metrics.memory.free %> MB</span>
                </div>
              </div>

              <!-- Swap -->
              <%= if @metrics.memory.swap.total > 0 do %>
                <div class="mt-4">
                  <div class="flex justify-between mb-2">
                    <span class="text-sm text-gray-400">Swap</span>
                    <span class="text-sm font-semibold"><%= @metrics.memory.swap.percent_used %>%</span>
                  </div>
                  <.progress_bar value={@metrics.memory.swap.percent_used} color="bg-yellow-500" size="sm" />
                  <p class="text-xs text-gray-400 mt-1">
                    <%= @metrics.memory.swap.used %> / <%= @metrics.memory.swap.total %> MB
                  </p>
                </div>
              <% end %>
            </div>
          </.metric_card>

          <!-- Network Traffic -->
          <.metric_card title="Network Traffic" icon="🌐">
            <div class="space-y-4">
              <div>
                <div class="flex justify-between items-center mb-2">
                  <span class="text-sm">Download</span>
                  <span class="text-xl font-bold text-purple-400">
                    <%= @metrics.network.download_speed_mbps %> MB/s
                  </span>
                </div>
                <p class="text-xs text-gray-400">
                  Total: <%= @metrics.network.total_download_mb %> MB
                </p>
              </div>

              <div>
                <div class="flex justify-between items-center mb-2">
                  <span class="text-sm">Upload</span>
                  <span class="text-xl font-bold text-orange-400">
                    <%= @metrics.network.upload_speed_mbps %> MB/s
                  </span>
                </div>
                <p class="text-xs text-gray-400">
                  Total: <%= @metrics.network.total_upload_mb %> MB
                </p>
              </div>

              <!-- Active Interfaces -->
              <%= if length(@metrics.network.interfaces) > 0 do %>
                <div class="mt-4">
                  <p class="text-xs text-gray-400 mb-2">Active Interfaces:</p>
                  <div class="space-y-1">
                    <%= for interface <- Enum.take(@metrics.network.interfaces, 3) do %>
                      <div class="text-xs">
                        <span class="font-mono text-blue-300"><%= interface.interface %></span>
                        <span class="text-gray-500 ml-2">
                          ↓ <%= interface.rx_mb %> MB ↑ <%= interface.tx_mb %> MB
                        </span>
                      </div>
                    <% end %>
                  </div>
                </div>
              <% end %>
            </div>
          </.metric_card>
        </div>

        <!-- Disk Usage -->
        <%= if length(@metrics.disk) > 0 do %>
          <div class="bg-gray-800 rounded-lg p-6 mb-6">
            <h2 class="text-xl font-semibold mb-4 flex items-center gap-2">
              <span>💿</span> Disk Usage
            </h2>
            <div class="space-y-4">
              <%= for disk <- @metrics.disk do %>
                <div>
                  <div class="flex justify-between mb-2">
                    <span class="font-mono text-sm"><%= disk.mount_point %></span>
                    <span class="text-sm">
                      <%= disk.used %> / <%= disk.total %> GB (<%= disk.percent_used %>%)
                    </span>
                  </div>
                  <.progress_bar 
                    value={disk.percent_used} 
                    color={disk_color(disk.percent_used)} 
                  />
                </div>
              <% end %>
            </div>
          </div>
        <% end %>

        <!-- Running Processes -->
        <div class="bg-gray-800 rounded-lg p-6">
          <h2 class="text-xl font-semibold mb-4 flex items-center gap-2">
            <span>⚙️</span> Running Processes (Top 15)
          </h2>
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="border-b border-gray-700">
                <tr class="text-left text-gray-400">
                  <th class="pb-2">PID</th>
                  <th class="pb-2">Command</th>
                  <th class="pb-2 text-right">CPU%</th>
                  <th class="pb-2 text-right">MEM%</th>
                  <th class="pb-2">Status</th>
                </tr>
              </thead>
              <tbody class="font-mono text-xs">
                <%= for process <- @metrics.processes do %>
                  <tr class="border-b border-gray-700/50 hover:bg-gray-700/30">
                    <td class="py-2 text-blue-400"><%= process.pid %></td>
                    <td class="py-2 truncate max-w-xs" title={process.command}>
                      <%= String.slice(process.command, 0, 50) %>
                    </td>
                    <td class="py-2 text-right">
                      <span class={cpu_color(process.cpu_percent)}>
                        <%= format_float(process.cpu_percent) %>%
                      </span>
                    </td>
                    <td class="py-2 text-right">
                      <%= format_float(process.mem_percent) %>%
                    </td>
                    <td class="py-2 text-gray-400"><%= process.stat %></td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Footer -->
        <div class="mt-6 text-center text-gray-500 text-sm">
          <p>Last updated: <%= Calendar.strftime(@metrics.timestamp, "%H:%M:%S") %></p>
          <p class="mt-1">Updates every second • Built with Phoenix LiveView</p>
        </div>
      </div>
    </div>
    """
  end

  # Components

  attr :title, :string, required: true
  attr :icon, :string, default: ""
  slot :inner_block, required: true

  def metric_card(assigns) do
    ~H"""
    <div class="bg-gray-800 rounded-lg p-6">
      <h2 class="text-lg font-semibold mb-4 flex items-center gap-2">
        <%= if @icon != "" do %>
          <span><%= @icon %></span>
        <% end %>
        <%= @title %>
      </h2>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :value, :integer, required: true
  attr :color, :string, default: "bg-blue-500"
  attr :size, :string, default: "md"

  def progress_bar(assigns) do
    ~H"""
    <div class={["w-full bg-gray-700 rounded-full overflow-hidden", 
                 @size == "sm" && "h-2" || "h-3"]}>
      <div 
        class={["h-full rounded-full transition-all duration-300", @color]}
        style={"width: #{min(@value, 100)}%"}
      >
      </div>
    </div>
    """
  end

  # Helper Functions

  defp disk_color(percent) when percent >= 90, do: "bg-red-500"
  defp disk_color(percent) when percent >= 75, do: "bg-yellow-500"
  defp disk_color(_), do: "bg-green-500"

  defp cpu_color(percent) when percent >= 80, do: "text-red-400"
  defp cpu_color(percent) when percent >= 50, do: "text-yellow-400"
  defp cpu_color(_), do: "text-green-400"

  defp format_float(value) when is_float(value), do: Float.round(value, 1)
  defp format_float(value), do: value
end
