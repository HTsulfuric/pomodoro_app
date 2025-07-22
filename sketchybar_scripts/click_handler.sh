#!/bin/bash

# SketchyBar Click Handler for Pomodoro Timer Integration
# Uses URL schemes for all commands - no CLI tool dependency
# Usage: click_handler.sh <command>
# Commands: toggle-timer, reset-timer, skip-phase, show-app

SCRIPT_NAME=$(basename "$0")

# Function to display usage information
show_usage() {
    echo "Usage: $SCRIPT_NAME <command>"
    echo ""
    echo "Available commands:"
    echo "  toggle-timer    Start/pause the timer (fast background)"
    echo "  reset-timer     Reset the current session (fast background)"
    echo "  skip-phase      Skip to the next phase (fast background)"
    echo "  show-app        Bring the app to foreground (activates window)"
    echo ""
    echo "Examples:"
    echo "  $SCRIPT_NAME toggle-timer"
    echo "  $SCRIPT_NAME show-app"
}

# Function to send command to the app using hybrid approach
send_command() {
    local command="$1"
    
    echo "📤 Sending command: $command"
    
    case "$command" in
        "toggle-timer")
            # Fast background command via URL scheme
            if open "pomodoro://toggle" 2>/dev/null; then
                echo "✅ Toggle command sent via URL scheme (background)"
                return 0
            else
                echo "❌ Failed to send toggle command via URL scheme"
                return 1
            fi
            ;;
        "reset-timer")
            # Fast background command via URL scheme
            if open "pomodoro://reset" 2>/dev/null; then
                echo "✅ Reset command sent via URL scheme (background)"
                return 0
            else
                echo "❌ Failed to send reset command via URL scheme"
                return 1
            fi
            ;;
        "skip-phase")
            # Fast background command via URL scheme
            if open "pomodoro://skip" 2>/dev/null; then
                echo "✅ Skip command sent via URL scheme (background)"
                return 0
            else
                echo "❌ Failed to send skip command via URL scheme"
                return 1
            fi
            ;;
        "show-app")
            # URL scheme for window activation (this should activate window)
            local url="pomodoro://show-app"
            if open "$url" 2>/dev/null; then
                echo "✅ Show-app command sent via URL (activates window)"
                return 0
            else
                echo "❌ Failed to send show-app command via URL"
                return 1
            fi
            ;;
        *)
            echo "❌ Unknown command: $command"
            return 1
            ;;
    esac
}

# Function to check if the Pomodoro app is running
is_app_running() {
    if pgrep -f "PomodoroTimer" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to launch the app if not running (background launch for CLI commands)
launch_app_if_needed() {
    local command="$1"
    
    if ! is_app_running; then
        echo "🚀 App not running, launching..."
        
        # For show-app, we'll let the URL scheme handle launching
        if [[ "$command" == "show-app" ]]; then
            echo "   Note: show-app command will launch and activate the app"
            return 0
        fi
        
        # For background commands, launch without activation
        open -a "PomodoroTimer" --hide 2>/dev/null || {
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
        
        echo "✅ App launched successfully (background)"
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
    
    # Launch app if needed with appropriate method for command type
    if ! launch_app_if_needed "$command"; then
        exit 1
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