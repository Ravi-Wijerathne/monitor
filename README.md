# System Monitor

**Real-Time Server Resource Monitor** built with **Elixir & Phoenix LiveView**

## Features

- **CPU Monitoring** - Overall + per-core usage, load averages
- **Memory Tracking** - RAM + Swap usage with percentages
- **GPU Monitoring** - NVIDIA/AMD/Intel GPU usage, VRAM, temperature, power
- **Disk Usage** - All partitions with color-coded warnings
- **Network Traffic** - Upload/download speeds in real-time
- **Process Management** - Top 15 processes by CPU usage
- **System Info** - Hostname, OS, uptime, kernel version
- **Auto-Updates** - Real-time updates every 1 second via WebSocket

---

## Requirements

- **Elixir** 1.14+
- **Erlang/OTP** 24+
- **OS**: Windows, Linux, or macOS

---

## Quick Start

### Automated Setup (Recommended)

**Windows:**
```batch
scripts\start.bat
```
or
```powershell
.\scripts\start.ps1
```

**Linux/macOS:**
```bash
./scripts/start.sh
```

The script will install dependencies, build assets, start the server, and open http://localhost:4000

### Manual Setup

**Linux/macOS:**
```bash
mix deps.get
mix assets.setup
mix assets.build
mix phx.server
```

**Windows:**
```bash
mix deps.get

cd assets
..\\_build\tailwind-x64\tailwind.exe -i css\app.css -o ..\priv\static\assets\app.css -c tailwind.config.js
cd ..
_build\esbuild-windows-x64-0.17.11\esbuild.exe assets\js\app.js --bundle --target=es2017 --outdir=priv\static\assets --external:phoenix --external:phoenix_html --external:phoenix_live_view --external:topbar

mix phx.server
```

Then open: **http://localhost:4000**

---

## First-Time Installation

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install elixir erlang erlang-dev inotify-tools
```

**macOS:**
```bash
brew install elixir
```

**Windows:**
```powershell
# Install Chocolatey (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Elixir
choco install elixir -y
```

---

## Testing

Run all tests:
```bash
mix test
```

Run tests with detailed output:
```bash
mix test --trace
```

Run a specific test file:
```bash
mix test test/monitor/metrics/cpu_test.exs
```

Run tests for a specific module:
```bash
mix test test/monitor/metrics/*
```

---

## Troubleshooting

**Port 4000 already in use:**
```bash
netstat -ano | findstr :4000
taskkill /PID <PID_NUMBER> /F
```

**Elixir not found:** Restart your terminal and verify with `elixir --version`

---

## License

MIT License
