# 🚀 Quick Start Guide

## Setup Instructions

Follow these steps to get your System Monitor up and running:

### 1. Install Dependencies

```powershell
mix deps.get
```

This will download all Elixir dependencies including Phoenix, LiveView, and other required packages.

### 2. Setup Assets (TailwindCSS & ESBuild)

```powershell
mix assets.setup
```

This installs Tailwind CSS and ESBuild for asset compilation.

### 3. Build Assets

```powershell
mix assets.build
```

This compiles your CSS and JavaScript files.

### 4. Start the Phoenix Server

```powershell
mix phx.server
```

Or if you want to run it in an interactive Elixir shell:

```powershell
iex -S mix phx.server
```

### 5. Open Your Browser

Navigate to: **http://localhost:4000**

You should see your real-time system monitor dashboard! 🎉

---

## Troubleshooting

### Issue: `:os_mon` not starting

If you see errors related to `:cpu_sup`, `:memsup`, or `:disksup`, ensure the `:os_mon` application is properly installed with your Erlang installation.

**Solution**: The application automatically starts `:os_mon` in `system_monitor.ex`, but if issues persist:

```elixir
# Run in IEx
Application.ensure_all_started(:os_mon)
```

### Issue: Assets not loading

If styles aren't appearing:

```powershell
# Clean and rebuild
Remove-Item -Recurse -Force priv/static/assets
mix assets.build
```

### Issue: Windows specific - Process list not showing

On Windows, the `tasklist` command might require administrator privileges. Run your terminal as administrator if you encounter permission issues.

### Issue: Port 4000 already in use

Change the port in `config/dev.exs`:

```elixir
config :monitor, MonitorWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4001],  # Changed to 4001
```

---

## What You Should See

Your dashboard will display:

✅ **CPU Usage** - Overall and per-core statistics
✅ **Memory Usage** - RAM and Swap utilization  
✅ **Network Traffic** - Upload/download speeds
✅ **Disk Usage** - All mounted drives/partitions
✅ **Running Processes** - Top 15 processes by CPU
✅ **System Info** - Hostname, OS, uptime, kernel

The dashboard **auto-updates every 1 second** - no refresh needed!

---

## Testing the Application

Run tests with:

```powershell
mix test
```

---

## Development Mode

In development, the server includes:

- 🔄 **Live reload** - Code changes automatically refresh the browser
- 🐛 **Debug errors** - Detailed error pages
- 📝 **Live code reloading** - No need to restart the server

---

## Production Build

To create a production release:

```powershell
# Set environment variables
$env:SECRET_KEY_BASE = (mix phx.gen.secret)
$env:MIX_ENV = "prod"

# Build assets
mix assets.deploy

# Create release
mix release

# Run
_build/prod/rel/monitor/bin/monitor.bat start
```

---

## Next Steps

- Customize the update interval in `lib/monitor/system_monitor.ex`
- Adjust the number of processes shown in `lib/monitor_web/live/dashboard_live.ex`
- Modify colors and styling in `assets/tailwind.config.js`
- Add authentication for production use
- Implement historical data tracking with a database

---

## Need Help?

Check the main `README.md` for full documentation and architecture details.

**Enjoy monitoring your system! 🖥️📊**
