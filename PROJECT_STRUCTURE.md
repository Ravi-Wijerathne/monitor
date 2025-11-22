# System Monitor - Project Files Overview

## Core Application Files

### Configuration (`config/`)
- `config.exs` - Main configuration
- `dev.exs` - Development environment settings
- `prod.exs` - Production environment settings
- `runtime.exs` - Runtime configuration
- `test.exs` - Test environment settings

### Application Core (`lib/monitor/`)
- `application.ex` - Application supervision tree
- `system_monitor.ex` - GenServer that collects and broadcasts metrics

### Metric Collectors (`lib/monitor/metrics/`)
- `cpu.ex` - CPU usage, load averages, per-core stats
- `memory.ex` - RAM and swap memory tracking
- `disk.ex` - Disk usage for all partitions
- `network.ex` - Network traffic and interface stats
- `processes.ex` - Running process information
- `system.ex` - System info (hostname, OS, uptime, kernel)

### Web Layer (`lib/monitor_web/`)
- `endpoint.ex` - Phoenix endpoint configuration
- `router.ex` - Route definitions
- `live/dashboard_live.ex` - Main dashboard LiveView
- `components/core_components.ex` - Reusable UI components
- `components/layouts.ex` - Layout templates
- `controllers/error_html.ex` - Error page handlers

### Assets (`assets/`)
- `js/app.js` - JavaScript application entry
- `css/app.css` - Main stylesheet with Tailwind
- `tailwind.config.js` - Tailwind CSS configuration
- `vendor/topbar.js` - Progress bar library

### Tests (`test/`)
- `test_helper.exs` - Test configuration
- `support/conn_case.ex` - Test case helpers
- `monitor_test.exs` - Sample tests

## Key Technologies Used

1. **Phoenix Framework** - Web framework
2. **Phoenix LiveView** - Real-time UI updates via WebSocket
3. **Erlang :os_mon** - System monitoring (`:cpu_sup`, `:memsup`, `:disksup`)
4. **Phoenix.PubSub** - Pub/Sub for broadcasting metrics
5. **TailwindCSS** - Utility-first CSS framework
6. **ESBuild** - JavaScript bundler

## Data Flow

1. `SystemMonitor` GenServer collects metrics every 1 second
2. Metrics are gathered from 6 collector modules
3. Data is broadcast via PubSub to topic "system_metrics"
4. `DashboardLive` subscribes to updates
5. LiveView pushes changes to browser via WebSocket
6. UI updates automatically without page refresh

## Customization Points

- **Update frequency**: `@update_interval` in `system_monitor.ex`
- **Process limit**: `Processes.collect(15)` in `dashboard_live.ex`
- **Styling**: `assets/tailwind.config.js` and `assets/css/app.css`
- **Colors**: Progress bar colors in `dashboard_live.ex`

## Dependencies (mix.exs)

- `phoenix` - Web framework
- `phoenix_live_view` - Real-time UI
- `phoenix_html` - HTML helpers
- `phoenix_live_dashboard` - Phoenix dashboard
- `phoenix_live_reload` - Development live reload
- `plug_cowboy` - HTTP server
- `jason` - JSON parser
- `telemetry_metrics` & `telemetry_poller` - Metrics
- `esbuild` & `tailwind` - Asset building
- `floki` - HTML parsing (testing)

## Special Notes

### Cross-Platform Compatibility
- Linux/macOS: Uses `ps`, `/proc/net/dev`, `uname`
- Windows: Uses `tasklist`, `netstat`, `ver`
- All platforms: Erlang built-ins for core metrics

### Performance
- GenServer pattern ensures efficient metric collection
- PubSub allows multiple concurrent viewers
- LiveView minimizes bandwidth (only sends diffs)

### Scalability
- Stateless LiveView processes
- Single GenServer handles all collection
- Can be extended to monitor remote servers
