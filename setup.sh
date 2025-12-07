#!/bin/bash
# Setup and run the System Monitor application

echo -e "\033[36m🚀 System Monitor - Setup Script\033[0m"
echo -e "\033[36m================================\n\033[0m"

# ==============================================================================
# Step 1: Check System Dependencies
# ==============================================================================

echo -e "\033[33m📋 Checking system dependencies...\033[0m"

# Check if Elixir is installed
if ! command -v elixir &> /dev/null; then
    echo -e "\033[31m❌ Elixir is not installed!\033[0m"
    echo -e "\033[31mPlease install Elixir from: https://elixir-lang.org/install.html\033[0m"
    echo ""
    echo "Installation commands:"
    echo "  macOS: brew install elixir"
    echo "  Ubuntu/Debian: sudo apt-get install elixir erlang"
    echo "  Fedora: sudo dnf install elixir"
    echo "  Arch Linux: sudo pacman -S elixir"
    exit 1
fi

ELIXIR_VERSION=$(elixir --version | grep "Elixir" | head -n1)
echo -e "\033[32m✅ Elixir: $ELIXIR_VERSION\033[0m"

# Check for required Erlang packages
MISSING_PACKAGES=()

# Check for erlang-dev (required for compilation)
if ! dpkg -l | grep -q "erlang-dev" 2>/dev/null && ! command -v brew &> /dev/null; then
    MISSING_PACKAGES+=("erlang-dev")
fi

# Check for erlang-os-mon (required for system monitoring)
if ! erl -eval 'application:load(os_mon), halt().' 2>/dev/null; then
    MISSING_PACKAGES+=("erlang-os-mon")
fi

# Check for inotify-tools (optional but recommended for development)
if ! command -v inotifywait &> /dev/null && [ "$(uname -s)" = "Linux" ]; then
    MISSING_PACKAGES+=("inotify-tools")
fi

# Install missing packages if any
if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo -e "\033[33m⚠️  Missing packages detected: ${MISSING_PACKAGES[*]}\033[0m"
    echo -e "\033[33m🔧 Attempting to install missing packages...\033[0m"
    
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu
        echo "Installing: ${MISSING_PACKAGES[*]}"
        sudo apt-get update -qq
        sudo apt-get install -y ${MISSING_PACKAGES[*]}
    elif command -v dnf &> /dev/null; then
        # Fedora
        sudo dnf install -y ${MISSING_PACKAGES[*]/erlang-/erlang-}
    elif command -v pacman &> /dev/null; then
        # Arch Linux
        sudo pacman -S --noconfirm inotify-tools
    elif command -v brew &> /dev/null; then
        # macOS
        echo -e "\033[33mℹ️  On macOS, fswatch will be used instead of inotify-tools\033[0m"
    else
        echo -e "\033[33m⚠️  Unable to automatically install packages. Please install manually:\033[0m"
        echo "  ${MISSING_PACKAGES[*]}"
    fi
    
    echo -e "\033[32m✅ System dependencies checked\033[0m"
else
    echo -e "\033[32m✅ All system dependencies are installed\033[0m"
fi

# ==============================================================================
# Step 2: Install Elixir Dependencies
# ==============================================================================

# Install dependencies
echo -e "\n\033[33m📦 Installing Elixir dependencies...\033[0m"
mix deps.get

if [ $? -ne 0 ]; then
    echo -e "\033[31m❌ Failed to install dependencies\033[0m"
    exit 1
fi

echo -e "\033[32m✅ Dependencies installed successfully\033[0m"

# ==============================================================================
# Step 3: Setup and Build Assets
# ==============================================================================

# Setup assets
echo -e "\n\033[33m🎨 Setting up assets (Tailwind & ESBuild)...\033[0m"
mix assets.setup

if [ $? -ne 0 ]; then
    echo -e "\033[31m❌ Failed to setup assets\033[0m"
    exit 1
fi

echo -e "\033[32m✅ Assets setup complete\033[0m"

# ==============================================================================
# Step 4: Build Assets
# ==============================================================================

# Build assets
echo -e "\n\033[33m🔨 Building assets...\033[0m"
mix assets.build

if [ $? -ne 0 ]; then
    echo -e "\033[31m❌ Failed to build assets\033[0m"
    exit 1
fi

echo -e "\033[32m✅ Assets built successfully\033[0m"

# Success message
echo -e "\n\033[32m✨ Setup Complete! ✨\n\033[0m"
echo -e "\033[36mTo start the server, run:\033[0m"
echo -e "  mix phx.server\n"
echo -e "\033[36mThen open your browser to:\033[0m"
echo -e "  http://localhost:4000\n"
echo -e "\033[33mPress any key to start the server now, or Ctrl+C to exit...\033[0m"
read -n 1 -s

echo -e "\n\033[36m🚀 Starting Phoenix server...\n\033[0m"
mix phx.server
