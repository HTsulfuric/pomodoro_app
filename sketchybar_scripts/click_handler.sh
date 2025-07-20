#!/bin/bash

# SketchyBar Click Handler for Pomodoro Timer Integration
# Sends commands to the SwiftUI app via custom URL scheme
# Usage: click_handler.sh <command>
# Commands: toggle-timer, reset-timer, skip-phase, show-app

SCRIPT_NAME=$(basename "$0")

# Function to display usage information
show_usage() {
    echo "Usage: $SCRIPT_NAME <command>"
    echo ""
    echo "Available commands:"
    echo "  toggle-timer    Start/pause the timer"
    echo "  reset-timer     Reset the current session"
    echo "  skip-phase      Skip to the next phase"
    echo "  show-app        Bring the app to foreground"
    echo ""
    echo "Examples:"
    echo "  $SCRIPT_NAME toggle-timer"
    echo "  $SCRIPT_NAME show-app"
}

# Function to send URL command to the app
send_command() {
    local command="$1"
    local url="pomodoro://$command"
    
    echo "📤 Sending command: $command"
    
    # Use 'open' to send the URL to the app
    if open "$url" 2>/dev/null; then
        echo "✅ Command sent successfully"
        return 0
    else
        echo "❌ Failed to send command"
        return 1
    fi
}

# Function to check if the Pomodoro app is running
is_app_running() {
    if pgrep -f "PomodoroTimer" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to launch the app if not running
launch_app_if_needed() {
    if ! is_app_running; then
        echo "🚀 App not running, launching..."
        open -a "PomodoroTimer" 2>/dev/null || {
            echo "❌ Failed to launch PomodoroTimer app"
            echo "   Make sure the app is installed and named 'PomodoroTimer'"
            return 1
        }
        
        # Wait a moment for the app to start
        sleep 1
        
        if ! is_app_running; then
            echo "❌ App failed to start"
            return 1
        fi
        
        echo "✅ App launched successfully"
    fi
    return 0
}

# Main execution
main() {
    local command="$1"
    
    # Check if command is provided
    if [[ -z "$command" ]]; then
        echo "❌ No command specified"
        show_usage
        exit 1
    fi
    
    # Validate command
    case "$command" in
        "toggle-timer"|"reset-timer"|"skip-phase"|"show-app")
            # Valid command
            ;;
        "help"|"-h"|"--help")
            show_usage
            exit 0
            ;;
        *)
            echo "❌ Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
    
    # Launch app if needed (except for show-app which will be handled by the URL)
    if [[ "$command" != "show-app" ]]; then
        if ! launch_app_if_needed; then
            exit 1
        fi
    fi
    
    # Send the command
    if send_command "$command"; then
        exit 0
    else
        exit 1
    fi
}

# Execute main function with all arguments
main "$@"