# System Monitor - PowerShell Startup Script
# More robust alternative to the .bat file

Write-Host ""
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host "                   SYSTEM MONITOR - AUTOMATED SETUP" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host ""

# Change to script directory
Set-Location $PSScriptRoot

# ==============================================================================
# Step 1: Check for Elixir Installation
# ==============================================================================

Write-Host "[1/6] Checking for Elixir installation..." -ForegroundColor Yellow

$elixirInstalled = Get-Command elixir -ErrorAction SilentlyContinue
if (-not $elixirInstalled) {
    # Try to refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    $elixirInstalled = Get-Command elixir -ErrorAction SilentlyContinue
}

if (-not $elixirInstalled) {
    Write-Host ""
    Write-Host "[ERROR] Elixir is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Elixir first:" -ForegroundColor Yellow
    Write-Host "  1. Open PowerShell as Administrator" -ForegroundColor White
    Write-Host "  2. Run: choco install elixir -y" -ForegroundColor White
    Write-Host "  OR download from: https://elixir-lang.org/install.html" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[OK] Elixir is installed" -ForegroundColor Green
elixir --version | Select-String "Elixir" | Write-Host

# Refresh PATH to ensure mix is available
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# ==============================================================================
# Step 2: Check and Install Mix Dependencies
# ==============================================================================

Write-Host ""
Write-Host "[2/6] Checking Mix dependencies..." -ForegroundColor Yellow

if (-not (Test-Path "deps")) {
    Write-Host "Installing Mix dependencies..." -ForegroundColor Yellow
    mix deps.get
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to install dependencies" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Host "[OK] Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "[OK] Dependencies already installed" -ForegroundColor Green
}

# ==============================================================================
# Step 3: Setup Tailwind CSS
# ==============================================================================

Write-Host ""
Write-Host "[3/6] Setting up Tailwind CSS..." -ForegroundColor Yellow

if (-not (Test-Path "_build\tailwind-x64\tailwind.exe")) {
    Write-Host "Setting up Tailwind CSS..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path "_build\tailwind-x64" | Out-Null
    
    # Check if user has manually downloaded it
    $tailwindDownload = "$env:USERPROFILE\Downloads\tailwindcss-windows-x64.exe"
    if (Test-Path $tailwindDownload) {
        Write-Host "Found Tailwind in Downloads, copying..." -ForegroundColor Yellow
        Copy-Item $tailwindDownload -Destination "_build\tailwind-x64\tailwind.exe" -Force
    } else {
        Write-Host "Attempting to download Tailwind CSS..." -ForegroundColor Yellow
        try {
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri "https://github.com/tailwindlabs/tailwindcss/releases/download/v3.3.2/tailwindcss-windows-x64.exe" `
                              -OutFile "_build\tailwind-x64\tailwind.exe" `
                              -TimeoutSec 30
        } catch {
            Write-Host "[WARNING] Auto-download failed. Please download manually from:" -ForegroundColor Yellow
            Write-Host "https://github.com/tailwindlabs/tailwindcss/releases/download/v3.3.2/tailwindcss-windows-x64.exe" -ForegroundColor White
            Write-Host "Save it to: $env:USERPROFILE\Downloads\" -ForegroundColor White
            Write-Host ""
            Read-Host "Press Enter when download is complete"
            
            if (Test-Path $tailwindDownload) {
                Copy-Item $tailwindDownload -Destination "_build\tailwind-x64\tailwind.exe" -Force
            } else {
                Write-Host "[ERROR] Tailwind CSS not found" -ForegroundColor Red
                Read-Host "Press Enter to exit"
                exit 1
            }
        }
    }
}
Write-Host "[OK] Tailwind CSS ready" -ForegroundColor Green

# ==============================================================================
# Step 4: Setup ESBuild
# ==============================================================================

Write-Host ""
Write-Host "[4/6] Setting up ESBuild..." -ForegroundColor Yellow

if (-not (Test-Path "_build\esbuild-windows-x64-0.17.11\esbuild.exe")) {
    Write-Host "Setting up ESBuild..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path "_build\esbuild-windows-x64-0.17.11" | Out-Null
    
    # Check if user has manually downloaded it
    $esbuildDownload = "$env:USERPROFILE\Downloads\win32-x64-0.17.11.tgz"
    if (Test-Path $esbuildDownload) {
        Write-Host "Found ESBuild in Downloads, extracting..." -ForegroundColor Yellow
        tar -xzf $esbuildDownload -C "_build\esbuild-windows-x64-0.17.11"
        Move-Item "_build\esbuild-windows-x64-0.17.11\package\esbuild.exe" "_build\esbuild-windows-x64-0.17.11\" -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "Installing ESBuild via Mix..." -ForegroundColor Yellow
        mix esbuild.install
    }
}
Write-Host "[OK] ESBuild ready" -ForegroundColor Green

# ==============================================================================
# Step 5: Build Assets
# ==============================================================================

Write-Host ""
Write-Host "[5/6] Building assets..." -ForegroundColor Yellow

# Create assets directory
New-Item -ItemType Directory -Force -Path "priv\static\assets" | Out-Null

# Build CSS
Write-Host "Building CSS..." -ForegroundColor Yellow
Set-Location assets
& "..\\_build\tailwind-x64\tailwind.exe" -i css\app.css -o ..\priv\static\assets\app.css -c tailwind.config.js 2>&1 | Out-Null
Set-Location ..

# Build JavaScript
Write-Host "Building JavaScript..." -ForegroundColor Yellow
& "_build\esbuild-windows-x64-0.17.11\esbuild.exe" assets\js\app.js --bundle --target=es2017 --outdir=priv\static\assets --external:phoenix --external:phoenix_html --external:phoenix_live_view --external:topbar 2>&1 | Out-Null

if (Test-Path "priv\static\assets\app.css") {
    Write-Host "[OK] Assets built successfully" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Asset build may have issues, but continuing..." -ForegroundColor Yellow
}

# ==============================================================================
# Step 6: Start Phoenix Server and Open Browser
# ==============================================================================

Write-Host ""
Write-Host "[6/6] Starting Phoenix server..." -ForegroundColor Yellow
Write-Host ""
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host "                    SYSTEM MONITOR IS STARTING" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Dashboard will open automatically at: http://localhost:4000" -ForegroundColor Green
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host ""

# Open browser after 3 seconds
Start-Job -ScriptBlock {
    Start-Sleep -Seconds 3
    Start-Process "http://localhost:4000"
} | Out-Null

# Start Phoenix server
mix phx.server

Write-Host ""
Write-Host "Server stopped." -ForegroundColor Yellow
Read-Host "Press Enter to exit"
