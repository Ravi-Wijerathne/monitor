#!/usr/bin/env pwsh
# Setup and run the System Monitor application

Write-Host "🚀 System Monitor - Setup Script" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Check if Elixir is installed
Write-Host "Checking for Elixir installation..." -ForegroundColor Yellow
if (!(Get-Command "elixir" -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Elixir is not installed!" -ForegroundColor Red
    Write-Host "Please install Elixir from: https://elixir-lang.org/install.html" -ForegroundColor Red
    exit 1
}

$elixirVersion = elixir --version | Select-String "Elixir" | Out-String
Write-Host "✅ $elixirVersion" -ForegroundColor Green

# Install dependencies
Write-Host "`n📦 Installing Elixir dependencies..." -ForegroundColor Yellow
mix deps.get

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green

# Setup assets
Write-Host "`n🎨 Setting up assets (Tailwind & ESBuild)..." -ForegroundColor Yellow
mix assets.setup

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to setup assets" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Assets setup complete" -ForegroundColor Green

# Build assets
Write-Host "`n🔨 Building assets..." -ForegroundColor Yellow
mix assets.build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build assets" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Assets built successfully" -ForegroundColor Green

# Success message
Write-Host "`n✨ Setup Complete! ✨`n" -ForegroundColor Green
Write-Host "To start the server, run:" -ForegroundColor Cyan
Write-Host "  mix phx.server`n" -ForegroundColor White
Write-Host "Then open your browser to:" -ForegroundColor Cyan
Write-Host "  http://localhost:4000`n" -ForegroundColor White
Write-Host "Press any key to start the server now, or Ctrl+C to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host "`n🚀 Starting Phoenix server...`n" -ForegroundColor Cyan
mix phx.server
