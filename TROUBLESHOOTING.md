# Troubleshooting Guide

Common issues and solutions for the Pomodoro Timer app.

## Quick Fixes

### App Won't Start
1. **Check macOS Version**: Requires macOS 13.0 or later
2. **Verify Installation**: Ensure app is in `/Applications` folder
3. **Restart**: Try force-quitting and restarting the app
4. **Reset Preferences**: Delete `~/Library/Preferences/com.local.PomodoroTimer.plist`

### Global Hotkey Not Working
**Issue**: `Opt+Shift+P` doesn't show overlay

**Solutions**:
1. **Check for Conflicts**: Other apps may use the same hotkey
2. **Use Menu Bar**: Click the 🍅 icon in menu bar → "Toggle Overlay"
3. **Use URL Scheme**: Run `open "pomodoro://show-app"` in Terminal
4. **Restart App**: Force-quit and restart to reinitialize hotkey registration

---

## Notifications

### Notifications Not Appearing
**Issue**: No notifications when timer completes

**Solutions**:
1. **Check System Preferences**:
   - Open System Preferences → Notifications
   - Find "Pomodoro Timer" in the list
   - Ensure "Allow Notifications" is enabled
   - Enable "Lock Screen" and "Banners"

2. **Reset Notification Permissions**:
   ```bash
   # Reset notification database (requires restart)
   sudo rm /var/db/UserNotificationCenter/*
   ```

3. **Check Do Not Disturb**: Disable Focus/Do Not Disturb mode

### Notifications Appear But No Sound
**Issue**: Silent notifications

**Solutions**:
1. **Check App Settings**: Test sound using the speaker button in the app
2. **System Volume**: Ensure system volume is not muted
3. **Notification Settings**: 
   - System Preferences → Notifications → Pomodoro Timer
   - Ensure "Play sound for notifications" is enabled

### Lock Screen Notifications Not Working
**Issue**: Notifications don't appear when Mac is locked

**Solutions**:
1. **Enable Lock Screen Notifications**:
   - System Preferences → Notifications → Pomodoro Timer
   - Check "Lock Screen" option
   - Ensure "Show previews" is set to "Always" or "When Unlocked"

2. **Check Focus Mode**: Focus modes can block lock screen notifications

---

## SketchyBar Integration

### SketchyBar Not Updating
**Issue**: Timer shows `--:--` or doesn't update

**Solutions**:
1. **Verify Installation**:
   ```bash
   ls -la ~/.config/sketchybar/helpers/pomodoro_app_*
   ```
   Should show symlinks to the scripts

2. **Reinstall Scripts**:
   ```bash
   cd sketchybar_scripts
   ./install.sh
   sketchybar --reload
   ```

3. **Check State File**:
   ```bash
   cat ~/.config/pomodoro-timer/state.json
   ```
   Should show current timer state

4. **Check SketchyBar Logs**:
   ```bash
   tail -f /tmp/sketchybar_*.log
   ```

### SketchyBar Clicks Not Working
**Issue**: Clicking SketchyBar item doesn't control timer

**Solutions**:
1. **Check URL Scheme Registration**:
   ```bash
   # Test URL scheme manually
   open "pomodoro://toggle"
   ```

2. **Verify Click Handler**:
   ```bash
   ~/.config/sketchybar/helpers/pomodoro_app_click.sh toggle-timer
   ```

3. **Reload SketchyBar**:
   ```bash
   sketchybar --reload
   ```

---

## Theme Issues

### Theme Picker Not Appearing
**Issue**: Pressing `T` doesn't show theme picker

**Solutions**:
1. **Ensure Overlay is Visible**: Theme picker only works when overlay is shown
2. **Check Key Focus**: Click on the overlay window first, then press `T`
3. **Use Menu Bar**: Right-click menu bar icon for theme options (if available)

### Theme Changes Not Applying
**Issue**: Selected theme doesn't change appearance

**Solutions**:
1. **Confirm Theme Selection**: Press `Enter` to confirm selection in theme picker
2. **Restart App**: Force-quit and restart to reload theme system
3. **Check Theme Registry**:
   - Themes should appear in picker automatically
   - If missing, check `ThemeRegistrationHelper.registerBuiltInThemes()` in code

### Custom Themes Not Loading
**Issue**: Custom theme doesn't appear in picker

**Solutions**:
1. **Verify Registration**: Ensure `MyTheme.register()` is called in `ThemeRegistrationHelper`
2. **Check Unique ID**: Theme ID must be unique
3. **Build and Run**: Themes are registered at app startup
4. **Debug Console**: Check for theme registration errors in console

---

## Performance Issues

### High CPU Usage
**Issue**: App uses too much CPU

**Solutions**:
1. **Check SketchyBar Integration**: Disable if not needed
2. **Update to Latest Version**: Performance improvements in v3.0+
3. **Reset State File**: Delete `~/.config/pomodoro-timer/state.json`
4. **Monitor Activity**: Use Activity Monitor to identify specific issues

### Slow UI Response
**Issue**: Interface feels sluggish

**Solutions**:
1. **Check Screen Resolution**: Very high resolution may affect performance
2. **Reduce Visual Effects**: Use simpler themes (Terminal theme is fastest)
3. **Close Other Apps**: Free up system resources
4. **Restart Mac**: Clear system caches

---

## Overlay Window Issues

### Overlay Won't Show
**Issue**: Overlay doesn't appear when triggered

**Solutions**:
1. **Use Multiple Methods**:
   - `Opt+Shift+P` (global hotkey)
   - Menu bar → "Toggle Overlay"
   - `open "pomodoro://show-app"`
   - URL: `pomodoro://show-app`

2. **Check Display Settings**: May appear on different monitor
3. **Reset Window Position**: Delete preferences to reset overlay position

### Overlay Won't Hide
**Issue**: Overlay stays visible

**Solutions**:
1. **Alfred-Style Auto-Hide**: Simply click on any other application - overlay automatically disappears
2. **Use Hide Keys**: Press `O` or `ESC` while overlay is focused  
3. **Menu Bar**: Click 🍅 → "Toggle Overlay"
4. **Force Quit**: If stuck, force-quit the app

**Note**: As of v3.0.1, the overlay behaves like Alfred - it automatically hides when you click on other applications for a cleaner user experience.

### Overlay Wrong Size/Position
**Issue**: Overlay appears in wrong location or size

**Solutions**:
1. **Multi-Monitor Setup**: Overlay follows active monitor
2. **Reset Preferences**: Delete app preferences to reset window positioning
3. **Screen Resolution**: App automatically adjusts for different screen sizes
4. **Manual Positioning**: Drag overlay window to desired position (position is remembered)

---

## Advanced Debugging

### Console Logging
View detailed app logs:
```bash
# View system logs
log stream --predicate 'subsystem CONTAINS "com.local.PomodoroTimer"'

# Or use Console.app
# Filter by "com.local.PomodoroTimer"
```

### Reset Everything
Complete app reset:
```bash
# Delete preferences
rm ~/Library/Preferences/com.local.PomodoroTimer.plist

# Delete state file
rm ~/.config/pomodoro-timer/state.json

# Reset notification permissions
sudo rm /var/db/UserNotificationCenter/*

# Restart app and Mac
```

### File Locations
Important app files:
- **Preferences**: `~/Library/Preferences/com.local.PomodoroTimer.plist`
- **State File**: `~/.config/pomodoro-timer/state.json`
- **SketchyBar Scripts**: `~/.config/sketchybar/helpers/pomodoro_app_*`

---

## Getting Help

### Before Reporting Issues
1. **Update to Latest Version**: Check if issue is fixed in recent updates
2. **Check This Guide**: Search for your specific issue above
3. **Try Basic Solutions**: Restart app, reset preferences, etc.
4. **Gather Information**:
   - macOS version
   - App version
   - Console logs (if relevant)
   - Steps to reproduce issue

### Report Bugs
Include the following information:
- **System Info**: macOS version, hardware details
- **App Version**: Check About menu for version number  
- **Issue Description**: What you expected vs. what happened
- **Reproduction Steps**: How to trigger the issue
- **Console Logs**: Any relevant error messages
- **Configuration**: Custom themes, SketchyBar setup, etc.

### Common Log Messages
Normal log messages (not errors):
```
🔋 Started background activity - preventing App Nap while timer runs
📊 Updated: Work Session - 24:59 - running: true
🔊 Playing phase change sound: Glass
```

Error messages to report:
```
❌ Failed to create overlay panel
❌ Notification permission error
❌ Failed to register Carbon hotkey
```

---

**Note**: Most issues can be resolved by restarting the app or resetting preferences. The app is designed to be robust and self-healing in most situations.