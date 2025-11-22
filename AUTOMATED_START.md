# 🚀 Quick Start Guide - Automated Launch

## Automated Startup Scripts

We've created two automated startup scripts for you:

### Option 1: Batch File (Recommended for Windows)

```batch
start.bat
```

**Double-click `start.bat`** or run from Command Prompt:
```cmd
start.bat
```

### Option 2: PowerShell Script (More Features)

```powershell
.\start.ps1
```

**Right-click `start.ps1` → Run with PowerShell** or from PowerShell:
```powershell
.\start.ps1
```

---

## What These Scripts Do Automatically

Both scripts perform the following steps:

### ✅ 1. Check Elixir Installation
- Verifies Elixir is installed
- Shows helpful error message if not found
- Refreshes PATH to detect newly installed Elixir

### ✅ 2. Install Dependencies
- Checks if Mix dependencies are installed
- Runs `mix deps.get` if needed
- Skips if already installed (saves time)

### ✅ 3. Setup Tailwind CSS
- Checks for Tailwind executable
- Auto-downloads from GitHub (PowerShell script)
- Falls back to manual download with instructions
- Copies from Downloads folder if already downloaded

### ✅ 4. Setup ESBuild
- Checks for ESBuild executable
- Extracts from downloaded archive if available
- Falls back to `mix esbuild.install`

### ✅ 5. Build Assets
- Compiles CSS with Tailwind
- Bundles JavaScript with ESBuild
- Creates production-ready assets

### ✅ 6. Start Server & Open Browser
- Starts Phoenix server on port 4000
- **Automatically opens browser** after 3 seconds
- Opens to http://localhost:4000

---

## First Time Setup

If this is your first time running:

1. **Ensure Elixir is installed**
   - If not: `choco install elixir -y`

2. **Run the script**
   - Double-click `start.bat` or
   - Run `.\start.ps1` in PowerShell

3. **If downloads fail**
   - Manually download required files:
     - **Tailwind**: https://github.com/tailwindlabs/tailwindcss/releases/download/v3.3.2/tailwindcss-windows-x64.exe
     - **ESBuild**: https://registry.npmjs.org/@esbuild/win32-x64/-/win32-x64-0.17.11.tgz
   - Save to: `C:\Users\<YourUsername>\Downloads\`
   - Re-run the script

4. **Browser opens automatically**
   - Dashboard loads at http://localhost:4000
   - Real-time monitoring begins!

---

## Subsequent Runs

After the first setup, the scripts will:
- Skip already installed dependencies (instant startup!)
- Rebuild assets only if needed
- Start server and open browser immediately

**Typical startup time: 5-10 seconds** ⚡

---

## Stopping the Server

Press `Ctrl+C` in the terminal window to stop the server.

---

## Troubleshooting

### Script won't run (PowerShell)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Elixir not found
- Ensure Elixir is installed: `choco install elixir -y`
- Restart PowerShell/CMD after installation
- Check: `elixir --version`

### Browser doesn't open automatically
- Manually open: http://localhost:4000
- Check if server started successfully (look for "Running MonitorWeb.Endpoint")

### Assets not loading
- The script rebuilds them automatically
- Manual rebuild: Run `start.bat` or `start.ps1` again

### Port 4000 already in use
- Stop any running instance
- Or change port in `config/dev.exs`

---

## Manual Commands (If Needed)

If you prefer manual control:

```powershell
# Install dependencies
mix deps.get

# Build assets
cd assets
..\\_build\tailwind-x64\tailwind.exe -i css\app.css -o ..\priv\static\assets\app.css -c tailwind.config.js
cd ..
_build\esbuild-windows-x64-0.17.11\esbuild.exe assets\js\app.js --bundle --target=es2017 --outdir=priv\static\assets --external:phoenix --external:phoenix_html --external:phoenix_live_view --external:topbar

# Start server
mix phx.server

# Open browser
start http://localhost:4000
```

---

## Features

Your automated startup script provides:

- 🔍 Dependency checking
- 📦 Automatic installation
- 🎨 Asset compilation
- 🚀 Server startup
- 🌐 Browser auto-launch
- ⚡ Fast subsequent startups
- 🛡️ Error handling with helpful messages

---

## Next Steps

Once the dashboard is running:

- Monitor CPU, Memory, Disk, Network in real-time
- View top 15 processes
- Watch metrics update every second
- Customize update intervals in code
- Extend with additional features

**Enjoy your automated system monitor!** 🎉
