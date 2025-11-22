# Real-Time Server Resource Monitor

🚀 **A powerful real-time system monitoring dashboard built with Elixir and Phoenix LiveView**

This is a web-based HTOP alternative that provides real-time monitoring of server resources including CPU, memory, disk, network, and running processes - all updated automatically without page refresh.

## ✨ Features

- **📊 Real-time CPU Monitoring**
  - Overall CPU usage percentage
  - Per-core usage visualization
  - Load averages (1m, 5m, 15m)

- **💾 Memory Statistics**
  - Total, used, and free RAM
  - Memory usage percentage
  - Swap memory tracking

- **💿 Disk Usage**
  - Multiple disk/partition monitoring
  - Used and free space
  - Usage percentage with color-coded alerts

- **🌐 Network Traffic**
  - Upload/download speeds (MB/s)
  - Total transferred data
  - Active network interfaces

- **⚙️ Process Management**
  - Top 15 processes by CPU usage
  - Process ID, name, CPU%, and memory%
  - Real-time process status

- **🖥️ System Information**
  - Hostname
  - Operating system
  - Uptime
  - Kernel version
  - System architecture

- **🔄 Auto-updating Dashboard**
  - Updates every 1 second via WebSocket
  - No page refresh needed
  - Multiple users can monitor simultaneously

## 🛠️ Tech Stack

- **Backend**: Elixir with Phoenix Framework
- **Real-time**: Phoenix LiveView (WebSocket-based)
- **System Metrics**: Erlang `:os_mon` (`:cpu_sup`, `:memsup`, `:disksup`)
- **Frontend**: TailwindCSS for styling
- **Architecture**: GenServer for metrics collection + PubSub for broadcasting

## 📋 Prerequisites

- Elixir 1.14 or later
- Erlang/OTP 25 or later
- Node.js 16+ (for asset compilation)

## 🚀 Installation & Setup

1. **Clone or navigate to the project directory**
   ```bash
   cd c:\Users\nmmsr\Documents\SLIIT\Projects\monitor
   ```

2. **Install dependencies**
   ```bash
   mix deps.get
   ```

3. **Install Node.js dependencies**
   ```bash
   cd assets && npm install && cd ..
   ```

4. **Setup assets**
   ```bash
   mix assets.setup
   ```

5. **Compile assets**
   ```bash
   mix assets.build
   ```

## 🏃 Running the Application

Start the Phoenix server:

```bash
mix phx.server
```

Or run inside IEx:

```bash
iex -S mix phx.server
```

Now visit [`http://localhost:4000`](http://localhost:4000) in your browser!

## 🏗️ Architecture

```
Browser (LiveView)
     ↑        ↓  (WebSocket)
Phoenix LiveView Process
     ↓
Telemetry Collector (GenServer)
     ↓
Erlang Built-ins (:cpu_sup, :memsup, etc.)
     ↓
System (CPU, Memory, Disk, Network)
```

### How It Works

1. **SystemMonitor GenServer** (`Monitor.SystemMonitor`)
   - Collects metrics every 1 second
   - Uses Erlang's `:os_mon` modules for reliable system data
   - Broadcasts updates via Phoenix.PubSub

2. **Metric Collectors** (in `lib/monitor/metrics/`)
   - `CPU` - CPU usage and load averages
   - `Memory` - RAM and swap usage
   - `Disk` - Disk space and usage
   - `Network` - Network traffic statistics
   - `Processes` - Running processes information
   - `System` - General system info

3. **DashboardLive** (`MonitorWeb.DashboardLive`)
   - Subscribes to PubSub for metric updates
   - Renders real-time dashboard
   - Updates automatically via LiveView

## 📁 Project Structure

```
monitor/
├── lib/
│   ├── monitor/
│   │   ├── application.ex           # Application supervision tree
│   │   ├── system_monitor.ex        # Main GenServer for metrics
│   │   └── metrics/                 # Metric collectors
│   │       ├── cpu.ex
│   │       ├── memory.ex
│   │       ├── disk.ex
│   │       ├── network.ex
│   │       ├── processes.ex
│   │       └── system.ex
│   └── monitor_web/
│       ├── endpoint.ex
│       ├── router.ex
│       ├── live/
│       │   └── dashboard_live.ex    # Main dashboard LiveView
│       └── components/
├── config/                          # Configuration files
├── assets/                          # Frontend assets
│   ├── css/
│   ├── js/
│   └── tailwind.config.js
└── mix.exs                          # Dependencies
```

## 🎨 UI Customization

The dashboard uses TailwindCSS. To customize colors or styling:

1. Edit `assets/tailwind.config.js` for theme customization
2. Modify `assets/css/app.css` for custom styles
3. Update `lib/monitor_web/live/dashboard_live.ex` for layout changes

## 🔧 Configuration

### Update Interval

To change the metric collection interval, edit `lib/monitor/system_monitor.ex`:

```elixir
@update_interval 1000  # milliseconds (default: 1 second)
```

### Process Limit

To show more/fewer processes, edit the collection limit in `dashboard_live.ex`:

```elixir
processes: Processes.collect(15)  # Change 15 to your desired number
```

## 🌐 Cross-Platform Support

The monitor automatically detects your operating system and uses appropriate commands:

- **Linux/macOS**: Uses `ps`, `/proc/net/dev`, `uname`
- **Windows**: Uses `tasklist`, `netstat`, `ver`
- **All platforms**: Erlang `:os_mon` for core metrics

## 🔐 Production Deployment

For production deployment:

1. Set environment variables:
   ```bash
   export SECRET_KEY_BASE=$(mix phx.gen.secret)
   export PHX_HOST=your-domain.com
   ```

2. Build release:
   ```bash
   MIX_ENV=prod mix assets.deploy
   MIX_ENV=prod mix release
   ```

3. Run the release:
   ```bash
   _build/prod/rel/monitor/bin/monitor start
   ```

## 🚀 Future Enhancements

Potential features to add:

- 📈 **Historical graphs** - CPU/Memory trends over time (using Chart.js)
- 🔔 **Alerts** - Notifications for high CPU/memory/disk usage
- 🖥️ **Multi-server monitoring** - Monitor multiple servers from one dashboard
- ⚡ **Process killer** - Kill processes from the UI
- 🔒 **Authentication** - Secure access with user login
- 💾 **Database logging** - Store metrics in PostgreSQL for historical analysis

## 📝 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. Fork the project
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📧 Contact

Built with ❤️ using Elixir and Phoenix LiveView

---

**Happy Monitoring! 🎉**
