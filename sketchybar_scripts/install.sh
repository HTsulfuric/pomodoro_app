#!/bin/bash

# SketchyBar Pomodoro Integration Installer
# Creates symlinks from project scripts to SketchyBar helpers directory

set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKETCHYBAR_HELPERS_DIR="$HOME/.config/sketchybar/helpers"

echo "🔧 Installing SketchyBar Pomodoro Integration"
echo "=============================================="

# Ensure SketchyBar helpers directory exists
if [[ ! -d "$SKETCHYBAR_HELPERS_DIR" ]]; then
    echo "❌ SketchyBar helpers directory not found: $SKETCHYBAR_HELPERS_DIR"
    echo "   Please install SketchyBar first"
    exit 1
fi

echo "📂 Project directory: $PROJECT_DIR"
echo "📂 SketchyBar helpers: $SKETCHYBAR_HELPERS_DIR"

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
echo "📋 Next steps:"
echo "1. Update your SketchyBar configuration to use the new scripts"
echo "2. Reload SketchyBar: sketchybar --reload"
echo "3. Start your Pomodoro Timer app"
echo ""
echo "📖 For configuration help, see:"
echo "   SKETCHYBAR_INTEGRATION_ARCHITECTURE.md"