#!/bin/bash

# SketchyBar Pomodoro Integration Installer
# Creates symlinks from project scripts to SketchyBar helpers directory

set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$PROJECT_DIR")"
CLI_PROJECT_DIR="$REPO_ROOT/pomodoro-cli"
SKETCHYBAR_HELPERS_DIR="$HOME/.config/sketchybar/helpers"
CLI_INSTALL_DIR="/usr/local/bin"

echo "🔧 Installing SketchyBar Pomodoro Integration"
echo "=============================================="

# Ensure SketchyBar helpers directory exists
if [[ ! -d "$SKETCHYBAR_HELPERS_DIR" ]]; then
    echo "❌ SketchyBar helpers directory not found: $SKETCHYBAR_HELPERS_DIR"
    echo "   Please install SketchyBar first"
    exit 1
fi

echo "📂 Project directory: $PROJECT_DIR"
echo "📂 Repository root: $REPO_ROOT"
echo "📂 SketchyBar helpers: $SKETCHYBAR_HELPERS_DIR"
echo "📂 CLI install directory: $CLI_INSTALL_DIR"

# Build and install pomodoro-cli helper tool
echo ""
echo "🔨 Building pomodoro-cli helper tool..."

if [[ ! -d "$CLI_PROJECT_DIR" ]]; then
    echo "❌ CLI project directory not found: $CLI_PROJECT_DIR"
    exit 1
fi

# Build the CLI tool
cd "$CLI_PROJECT_DIR"
if ! swift build -c release; then
    echo "❌ Failed to build pomodoro-cli"
    exit 1
fi

echo "✅ CLI tool built successfully"

# Install the CLI binary
CLI_BINARY="$CLI_PROJECT_DIR/.build/release/pomodoro-cli"
if [[ ! -f "$CLI_BINARY" ]]; then
    echo "❌ CLI binary not found: $CLI_BINARY"
    exit 1
fi

echo "📦 Installing CLI tool to $CLI_INSTALL_DIR..."

# Create install directory if it doesn't exist
if [[ ! -d "$CLI_INSTALL_DIR" ]]; then
    echo "   Creating $CLI_INSTALL_DIR..."
    sudo mkdir -p "$CLI_INSTALL_DIR"
fi

# Copy the binary with sudo (since /usr/local/bin typically requires admin)
if sudo cp "$CLI_BINARY" "$CLI_INSTALL_DIR/pomodoro-cli"; then
    echo "✅ CLI tool installed successfully"
    echo "   Location: $CLI_INSTALL_DIR/pomodoro-cli"
else
    echo "❌ Failed to install CLI tool (check permissions)"
    exit 1
fi

# Make sure it's executable
sudo chmod +x "$CLI_INSTALL_DIR/pomodoro-cli"

# Return to project directory
cd "$PROJECT_DIR"

# Remove existing files/symlinks if they exist
echo "🧹 Cleaning up existing files..."
rm -f "$SKETCHYBAR_HELPERS_DIR/pomodoro_app_update.sh"
rm -f "$SKETCHYBAR_HELPERS_DIR/pomodoro_app_click.sh"

# Create symlinks
echo "🔗 Creating symlinks..."

# Update script symlink
if [[ -f "$PROJECT_DIR/update_state.sh" ]]; then
    ln -s "$PROJECT_DIR/update_state.sh" "$SKETCHYBAR_HELPERS_DIR/pomodoro_app_update.sh"
    echo "   ✅ update_state.sh -> pomodoro_app_update.sh"
else
    echo "   ❌ update_state.sh not found"
    exit 1
fi

# Click handler symlink
if [[ -f "$PROJECT_DIR/click_handler.sh" ]]; then
    ln -s "$PROJECT_DIR/click_handler.sh" "$SKETCHYBAR_HELPERS_DIR/pomodoro_app_click.sh"
    echo "   ✅ click_handler.sh -> pomodoro_app_click.sh"
else
    echo "   ❌ click_handler.sh not found"
    exit 1
fi

# Make scripts executable
chmod +x "$PROJECT_DIR/update_state.sh"
chmod +x "$PROJECT_DIR/click_handler.sh"

echo ""
echo "🎉 Installation complete!"
echo ""
echo "📋 What was installed:"
echo "• CLI helper tool: $CLI_INSTALL_DIR/pomodoro-cli (fast background commands)"
echo "• SketchyBar scripts with hybrid approach (CLI + URL schemes)"
echo ""
echo "📋 Next steps:"
echo "1. Update your SketchyBar configuration to use the new scripts"
echo "2. Reload SketchyBar: sketchybar --reload"
echo "3. Start your Pomodoro Timer app"
echo ""
echo "⚡ Performance note:"
echo "• toggle/reset/skip commands now use lightning-fast CLI (no window activation)"
echo "• show-app command uses URL scheme (activates window as intended)"
echo ""
echo "📖 For configuration help, see:"
echo "   SKETCHYBAR_INTEGRATION_ARCHITECTURE.md"