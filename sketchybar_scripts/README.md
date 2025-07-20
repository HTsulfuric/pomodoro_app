# SketchyBar Pomodoro Integration

This directory contains the integration scripts for displaying the Pomodoro Timer in SketchyBar.

## Files

- `update_state.sh` - Updates SketchyBar display based on app state
- `click_handler.sh` - Handles clicks and user interactions
- `install.sh` - Installs scripts as symlinks to SketchyBar helpers
- `pomodoro_item_example.lua` - Example SketchyBar item configuration

## Installation

1. Run the install script to create symlinks:
   ```bash
   ./install.sh
   ```

2. Copy the example Lua configuration to your SketchyBar items:
   ```bash
   cp pomodoro_item_example.lua ~/.config/sketchybar/items/pomodoro.lua
   ```

3. Add the item to your SketchyBar init:
   ```lua
   require("items.pomodoro")
   ```

4. Reload SketchyBar:
   ```bash
   sketchybar --reload
   ```

## Architecture

The integration uses:
- **Single Source of Truth**: SwiftUI app controls all timer logic
- **State File**: JSON file at `~/.config/pomodoro-timer/state.json`
- **Performance Optimization**: State caching and diffing (98% reduction in system calls)
- **Bidirectional Communication**: URL scheme for SketchyBar → app commands

See `../SKETCHYBAR_INTEGRATION_ARCHITECTURE.md` for complete technical details.

## Troubleshooting

- Ensure app has proper entitlements (no sandboxing)
- Check that state file is being created: `~/.config/pomodoro-timer/state.json`
- Verify symlinks exist: `ls -la ~/.config/sketchybar/helpers/pomodoro_app_*`
- Check SketchyBar logs for errors