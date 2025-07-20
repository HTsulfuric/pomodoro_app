#!/bin/bash

# SketchyBar Update Script for Pomodoro Timer Integration
# Reads state from SwiftUI app's JSON file and updates SketchyBar display
# This script should be called by SketchyBar periodically (e.g., update_freq = 2)

STATE_FILE="$HOME/.config/pomodoro-timer/state.json"

# Function to set disconnected state
set_disconnected_state() {
    sketchybar --set pomodoro_item \
        label="--:--" \
        icon="􀐱" \
        icon.color="0xff7f8490"
    echo "⚠️ App disconnected - showing idle state"
}

# Function to validate JSON structure
validate_json() {
    local file="$1"
    if ! jq empty "$file" 2>/dev/null; then
        echo "❌ Invalid JSON in state file"
        return 1
    fi
    return 0
}

# Function to check if app process is running
is_app_running() {
    local pid="$1"
    if ps -p "$pid" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Main execution
main() {
    # Check if state file exists
    if [[ ! -f "$STATE_FILE" ]]; then
        set_disconnected_state
        exit 0
    fi

    # Validate JSON format
    if ! validate_json "$STATE_FILE"; then
        set_disconnected_state
        exit 0
    fi

    # Read state values
    APP_PID=$(jq -r '.appPid // empty' "$STATE_FILE" 2>/dev/null)
    PHASE=$(jq -r '.phase // empty' "$STATE_FILE" 2>/dev/null)
    TIME_REMAINING=$(jq -r '.timeRemaining // empty' "$STATE_FILE" 2>/dev/null)
    SESSION_COUNT=$(jq -r '.sessionCount // empty' "$STATE_FILE" 2>/dev/null)
    IS_RUNNING=$(jq -r '.isRunning | tostring // empty' "$STATE_FILE" 2>/dev/null)
    LAST_UPDATE=$(jq -r '.lastUpdateTimestamp // empty' "$STATE_FILE" 2>/dev/null)

    # Validate required fields
    if [[ -z "$APP_PID" || -z "$PHASE" || -z "$TIME_REMAINING" || -z "$IS_RUNNING" || -z "$LAST_UPDATE" ]]; then
        echo "❌ Missing required fields in state file"
        set_disconnected_state
        exit 0
    fi

    # Check if app process is still running
    if ! is_app_running "$APP_PID"; then
        echo "⚠️ App process $APP_PID is no longer running"
        set_disconnected_state
        exit 0
    fi

    # Check if state is stale (older than 10 seconds)
    CURRENT_TIME=$(date +%s)
    LAST_UPDATE_SECONDS=${LAST_UPDATE%.*}  # Remove decimal part
    STALENESS=$((CURRENT_TIME - LAST_UPDATE_SECONDS))

    if [[ $STALENESS -gt 10 ]]; then
        echo "⚠️ State is stale (age: ${STALENESS}s)"
        set_disconnected_state
        exit 0
    fi

    # Format time display (MM:SS)
    if [[ "$TIME_REMAINING" =~ ^[0-9]+$ ]] && [[ "$TIME_REMAINING" -ge 0 ]]; then
        MINUTES=$((TIME_REMAINING / 60))
        SECONDS=$((TIME_REMAINING % 60))
        TIME_DISPLAY=$(printf "%02d:%02d" $MINUTES $SECONDS)
    else
        TIME_DISPLAY="--:--"
    fi

    # Determine icon and color based on phase and running state
    case "$PHASE" in
        "Work Session")
            ICON="􀐱"  # Timer icon
            if [[ "$IS_RUNNING" == "true" ]]; then
                COLOR="0xffa3be8c"  # Nord green
            else
                COLOR="0xff7f8490"  # Nord gray (paused)
            fi
            ;;
        "Short Break")
            ICON="􀁰"  # Break icon
            if [[ "$IS_RUNNING" == "true" ]]; then
                COLOR="0xffebcb8b"  # Nord yellow
            else
                COLOR="0xff7f8490"  # Nord gray (paused)
            fi
            ;;
        "Long Break")
            ICON="􀁰"  # Break icon
            if [[ "$IS_RUNNING" == "true" ]]; then
                COLOR="0xffd08770"  # Nord orange
            else
                COLOR="0xff7f8490"  # Nord gray (paused)
            fi
            ;;
        *)
            ICON="􀐱"
            COLOR="0xff7f8490"  # Default gray
            ;;
    esac

    # Update SketchyBar display
    sketchybar --set pomodoro_item \
        label="$TIME_DISPLAY" \
        icon="$ICON" \
        icon.color="$COLOR"

    # Optional: Update session counter if you have a separate item
    # sketchybar --set pomodoro_sessions label="$SESSION_COUNT/4"

    # Debug output (comment out in production)
    echo "📊 Updated: $PHASE - $TIME_DISPLAY - running: $IS_RUNNING"
}

# Execute main function
main "$@"