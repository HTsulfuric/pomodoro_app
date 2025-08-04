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

# Function to render progress gauge using blocks
render_gauge() {
    local progress=$1
    local total_blocks=10
    
    # Calculate filled blocks (round to nearest)
    local filled_blocks=$(printf "%.0f" $(echo "($progress * $total_blocks) / 100" | bc -l))
    
    # Ensure bounds
    [[ $filled_blocks -lt 0 ]] && filled_blocks=0
    [[ $filled_blocks -gt $total_blocks ]] && filled_blocks=$total_blocks
    
    # Build gauge string
    local gauge=""
    for ((i=1; i<=total_blocks; i++)); do
        if [[ $i -le $filled_blocks ]]; then
            gauge+="█"  # Filled block
        else
            gauge+="░"  # Empty block
        fi
    done
    
    echo "$gauge"
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

    # Read state values (gauge-based system)
    APP_PID=$(jq -r '.appPid // empty' "$STATE_FILE" 2>/dev/null)
    PHASE=$(jq -r '.phase // empty' "$STATE_FILE" 2>/dev/null)
    TIME_REMAINING=$(jq -r '.timeRemaining // empty' "$STATE_FILE" 2>/dev/null)
    PROGRESS_PERCENT=$(jq -r '.progressPercent // empty' "$STATE_FILE" 2>/dev/null)
    TOTAL_DURATION=$(jq -r '.totalDuration // empty' "$STATE_FILE" 2>/dev/null)
    SESSION_COUNT=$(jq -r '.sessionCount // empty' "$STATE_FILE" 2>/dev/null)
    IS_RUNNING=$(jq -r '.isRunning | tostring // empty' "$STATE_FILE" 2>/dev/null)
    LAST_UPDATE=$(jq -r '.lastUpdateTimestamp // empty' "$STATE_FILE" 2>/dev/null)

    # Validate required fields (gauge-based system)
    if [[ -z "$APP_PID" || -z "$PHASE" || -z "$PROGRESS_PERCENT" || -z "$IS_RUNNING" || -z "$LAST_UPDATE" ]]; then
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

    # Generate gauge display from progress percentage
    if [[ "$PROGRESS_PERCENT" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$PROGRESS_PERCENT >= 0" | bc -l) )); then
        GAUGE_DISPLAY=$(render_gauge "$PROGRESS_PERCENT")
        # Keep time for tooltip/debugging (preserved as per user request)
        if [[ "$TIME_REMAINING" =~ ^[0-9]+$ ]] && [[ "$TIME_REMAINING" -ge 0 ]]; then
            MINUTES=$((TIME_REMAINING / 60))
            SECONDS=$((TIME_REMAINING % 60))
            TIME_TOOLTIP=$(printf "%02d:%02d" $MINUTES $SECONDS)
        else
            TIME_TOOLTIP="--:--"
        fi
    else
        GAUGE_DISPLAY="░░░░░░░░░░"  # Empty gauge fallback
        TIME_TOOLTIP="--:--"
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

    # Update SketchyBar display with gauge
    sketchybar --set pomodoro_item \
        label="$GAUGE_DISPLAY" \
        icon="$ICON" \
        icon.color="$COLOR"

    # Optional: Update session counter if you have a separate item
    # sketchybar --set pomodoro_sessions label="$SESSION_COUNT/4"

    # Debug output (comment out in production)
    echo "📊 Updated: $PHASE - $GAUGE_DISPLAY ($TIME_TOOLTIP) - running: $IS_RUNNING - progress: ${PROGRESS_PERCENT}%"
}

# Execute main function
main "$@"