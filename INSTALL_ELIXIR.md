# 🔧 Installing Elixir on Windows

## You Need to Install Elixir First!

The setup script detected that Elixir is not installed on your system. Here's how to install it:

## Option 1: Using Chocolatey (Recommended - Easiest)

If you have Chocolatey package manager installed:

```powershell
# Run PowerShell as Administrator
choco install elixir
```

**Don't have Chocolatey?** Install it first:
```powershell
# Run in PowerShell as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Then install Elixir:
```powershell
choco install elixir
```

## Option 2: Using Scoop (Alternative)

If you prefer Scoop package manager:

```powershell
scoop install elixir
```

**Don't have Scoop?** Install it first:
```powershell
# Run in PowerShell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
```

Then install Elixir:
```powershell
scoop install elixir
```

## Option 3: Web Installer (Manual)

1. **Download the installer** from: https://elixir-lang.org/install.html#windows
2. Click on **"Windows Installer"** link
3. Download and run the `.exe` installer
4. Follow the installation wizard
5. Restart your PowerShell terminal

## After Installation

1. **Close and reopen PowerShell** (important!)
2. **Verify installation**:
   ```powershell
   elixir --version
   ```

   You should see output like:
   ```
   Erlang/OTP 26 [erts-14.x] [64-bit] [smp:8:8] [async-threads:1]
   Elixir 1.15.x (compiled with Erlang/OTP 26)
   ```

3. **Run the setup script again**:
   ```powershell
   cd c:\Users\nmmsr\Documents\SLIIT\Projects\monitor
   .\setup.ps1
   ```

## Troubleshooting

### Problem: Command not found after installation

**Solution**: Close and reopen your PowerShell terminal, or add Elixir to your PATH manually.

### Problem: Erlang not installed

Elixir requires Erlang. Most installers include it, but if not:
- Chocolatey: `choco install erlang`
- Scoop: `scoop install erlang`
- Manual: Download from https://www.erlang.org/downloads

### Problem: Permission denied

**Solution**: Run PowerShell as Administrator for installation.

---

## Quick Reference: Installation Commands

### Chocolatey (Recommended)
```powershell
# As Administrator
choco install elixir
```

### Scoop
```powershell
scoop install elixir
```

### Manual
Visit: https://elixir-lang.org/install.html#windows

---

## Once Elixir is Installed

Run the setup script:
```powershell
.\setup.ps1
```

Or manually:
```powershell
mix deps.get
mix assets.setup
mix assets.build
mix phx.server
```

Then open: http://localhost:4000

---

## Need More Help?

- Elixir Installation Guide: https://elixir-lang.org/install.html
- Elixir Getting Started: https://elixir-lang.org/getting-started/introduction.html
- Phoenix Framework: https://hexdocs.pm/phoenix/installation.html

**After installing Elixir, come back and run `.\setup.ps1` again!**
