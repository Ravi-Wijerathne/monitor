#!/bin/bash
# ==============================================================================
# System Monitor - Automated Setup and Launch Script
# ==============================================================================

set -e

echo ""
echo "==============================================================================="
echo "                   SYSTEM MONITOR - AUTOMATED SETUP"
echo "==============================================================================="
echo ""

# Change to parent directory (project root)
cd "$(dirname "$0")/.."

# ==============================================================================
# Step 0: Check Critical System Dependencies
# ==============================================================================

echo "[0/6] Checking critical system dependencies..."

# Check for erlang-dev
if ! [ -f "/usr/lib/erlang/lib/public_key-"*"/include/OTP-PUB-KEY.hrl" ] && ! command -v brew &> /dev/null; then
    echo "[WARNING] erlang-dev not found - required for compilation"
    echo "Installing erlang-dev..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y erlang-dev
    fi
fi

# Check for erlang-os-mon
if ! erl -eval 'application:load(os_mon), halt().' 2>/dev/null; then
    echo "[WARNING] erlang-os-mon not found - required for system monitoring"
    echo "Installing erlang or erlang-os-mon..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y erlang-os-mon || sudo apt-get install -y erlang
    fi
fi

# Check for inotify-tools (optional)
if ! command -v inotifywait &> /dev/null && [ "$(uname -s)" = "Linux" ]; then
    echo "[INFO] inotify-tools not found - live reload will be disabled"
    echo "To enable live reload, install: sudo apt-get install inotify-tools"
fi

echo "[OK] System dependencies checked"

# ==============================================================================
# Step 1: Check for Elixir Installation
# ==============================================================================

echo "[1/7] Checking for Elixir installation..."
if ! command -v elixir &> /dev/null; then
    echo ""
    echo "[ERROR] Elixir is not installed!"
    echo ""
    echo "Please install Elixir first:"
    echo "  macOS: brew install elixir"
    echo "  Ubuntu/Debian: sudo apt-get install elixir"
    echo "  OR download from: https://elixir-lang.org/install.html"
    echo ""
    exit 1
fi
echo "[OK] Elixir is installed"
elixir --version | grep "Elixir"

# ==============================================================================
# Step 2: Check and Install Mix Dependencies
# ==============================================================================

echo ""
echo "[2/7] Checking Mix dependencies..."
if [ ! -d "deps" ]; then
    echo "Installing Mix dependencies..."
    mix deps.get
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to install dependencies"
        exit 1
    fi
    echo "[OK] Dependencies installed"
else
    echo "[OK] Dependencies already installed"
fi

# ==============================================================================
# Step 3: Setup Tailwind CSS
# ==============================================================================

echo ""
echo "[3/7] Setting up Tailwind CSS..."

# Determine the correct Tailwind binary for the platform
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Linux)
        if [ "$ARCH" = "x86_64" ]; then
            TAILWIND_TARGET="tailwindcss-linux-x64"
            TAILWIND_DIR="_build/tailwind-linux-x64"
        elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
            TAILWIND_TARGET="tailwindcss-linux-arm64"
            TAILWIND_DIR="_build/tailwind-linux-arm64"
        else
            echo "[ERROR] Unsupported architecture: $ARCH"
            exit 1
        fi
        TAILWIND_BIN="$TAILWIND_DIR/tailwind"
        ;;
    Darwin)
        if [ "$ARCH" = "x86_64" ]; then
            TAILWIND_TARGET="tailwindcss-macos-x64"
            TAILWIND_DIR="_build/tailwind-macos-x64"
        elif [ "$ARCH" = "arm64" ]; then
            TAILWIND_TARGET="tailwindcss-macos-arm64"
            TAILWIND_DIR="_build/tailwind-macos-arm64"
        else
            echo "[ERROR] Unsupported architecture: $ARCH"
            exit 1
        fi
        TAILWIND_BIN="$TAILWIND_DIR/tailwind"
        ;;
    *)
        echo "[ERROR] Unsupported operating system: $OS"
        exit 1
        ;;
esac

if [ ! -f "$TAILWIND_BIN" ]; then
    echo "Downloading Tailwind CSS..."
    mkdir -p "$TAILWIND_DIR"
    
    # Check if user has manually downloaded it
    if [ -f "$HOME/Downloads/$TAILWIND_TARGET" ]; then
        echo "Found Tailwind in Downloads, copying..."
        cp "$HOME/Downloads/$TAILWIND_TARGET" "$TAILWIND_BIN"
        chmod +x "$TAILWIND_BIN"
    else
        echo "Downloading Tailwind CSS from GitHub..."
        TAILWIND_URL="https://github.com/tailwindlabs/tailwindcss/releases/download/v3.3.2/$TAILWIND_TARGET"
        if command -v curl &> /dev/null; then
            curl -L -o "$TAILWIND_BIN" "$TAILWIND_URL"
        elif command -v wget &> /dev/null; then
            wget -O "$TAILWIND_BIN" "$TAILWIND_URL"
        else
            echo "[ERROR] Neither curl nor wget is available. Please install one of them."
            exit 1
        fi
        chmod +x "$TAILWIND_BIN"
    fi
fi
echo "[OK] Tailwind CSS ready"

# ==============================================================================
# Step 4: Setup ESBuild
# ==============================================================================

echo ""
echo "[4/7] Setting up ESBuild..."

# Determine the correct ESBuild binary path
case "$OS" in
    Linux)
        if [ "$ARCH" = "x86_64" ]; then
            ESBUILD_DIR="_build/esbuild-linux-x64-0.17.11"
        elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
            ESBUILD_DIR="_build/esbuild-linux-arm64-0.17.11"
        fi
        ;;
    Darwin)
        if [ "$ARCH" = "x86_64" ]; then
            ESBUILD_DIR="_build/esbuild-darwin-x64-0.17.11"
        elif [ "$ARCH" = "arm64" ]; then
            ESBUILD_DIR="_build/esbuild-darwin-arm64-0.17.11"
        fi
        ;;
esac

if [ ! -f "$ESBUILD_DIR/esbuild" ]; then
    echo "Installing ESBuild via Mix..."
    mix esbuild.install
fi
echo "[OK] ESBuild ready"

# ==============================================================================
# Step 5: Build Assets
# ==============================================================================

echo ""
echo "[5/7] Building assets..."

# Create assets directory
mkdir -p "priv/static/assets"

# Build CSS
echo "Building CSS..."
cd assets
"../$TAILWIND_BIN" -i css/app.css -o ../priv/static/assets/app.css -c tailwind.config.js > /dev/null 2>&1 || true
cd ..

# Build JavaScript
echo "Building JavaScript..."
"$ESBUILD_DIR/esbuild" assets/js/app.js --bundle --target=es2017 --outdir=priv/static/assets --external:phoenix --external:phoenix_html --external:phoenix_live_view --external:topbar > /dev/null 2>&1 || true

if [ -f "priv/static/assets/app.css" ]; then
    echo "[OK] Assets built successfully"
else
    echo "[WARNING] Asset build may have issues, but continuing..."
fi

# ==============================================================================
# Step 6: Start Phoenix Server and Open Browser
# ==============================================================================

echo ""
echo "[6/7] Starting Phoenix server..."
echo ""
echo "==============================================================================="
echo "                    SYSTEM MONITOR IS STARTING"
echo "==============================================================================="
echo ""
echo "Dashboard will open automatically at: http://localhost:4000"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""
echo "==============================================================================="
echo ""

# Wait 3 seconds then open browser
(sleep 3 && xdg-open http://localhost:4000 2>/dev/null || open http://localhost:4000 2>/dev/null || echo "Please open http://localhost:4000 in your browser") &

# Start Phoenix server
mix phx.server

# If server stops, pause to show any errors
echo ""
echo "Server stopped."
read -p "Press Enter to exit..."
