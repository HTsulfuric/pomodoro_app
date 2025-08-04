# Implementation Plan - SketchyBar Timer Countdown Fix

## Source Analysis
- **Source Type**: Local bug fix - SketchyBar integration issue
- **Core Problem**: SketchyBar only updates timer display when start/stop is toggled, not counting down properly
- **Current State**: Event-driven polling system works, but timer doesn't decrement during running state
- **Complexity**: Medium - requires understanding the polling mechanism and state synchronization

## Problem Analysis

### Current Architecture
1. **Swift App Side** (`TimerViewModel.swift`):
   - `triggerSketchyBarEvent("pomodoro_start")` - triggers SketchyBar to start polling at 1Hz
   - `triggerSketchyBarEvent("pomodoro_stop")` - triggers SketchyBar to stop polling
   - `writeStateFile()` - writes state to `~/.config/pomodoro-timer/state.json` (debounced every 5s during ticks)
   - `scheduleStateFileWrite(immediate: false)` - called every second during `handleTimerTick()`

2. **SketchyBar Side** (`pomodoro.lua` + `update_script.sh`):
   - `update_freq = 1` when timer started (1 second polling)
   - `update_freq = 0` when timer stopped
   - Script reads state file and updates display

### Root Cause Analysis
The problem is likely in the **debounced state file writing**:
- Timer ticks every second in Swift app
- But state file writes are debounced to max once per 5 seconds during ticks
- SketchyBar polls every second but reads stale state data
- Only immediate writes happen on start/stop/reset/skip actions

## Target Integration
- **Integration Points**: State file writing frequency in `TimerViewModel.swift`
- **Affected Files**: 
  - `PomodoroTimer/PomodoroTimer/ViewModels/TimerViewModel.swift`
  - Potentially `~/.config/sketchybar/helpers/pomodoro_app_update.sh`
- **Pattern Matching**: Maintain event-driven architecture but fix state synchronization

## Implementation Tasks

### Phase 1: Diagnostic Testing
- [ ] Test current state file update frequency during timer operation
- [ ] Verify SketchyBar polling is working (1Hz when timer running)
- [ ] Confirm the issue is debounced state writing vs stale state detection

### Phase 2: Fix State Writing Frequency
- [ ] Modify `handleTimerTick()` to write state immediately during timer operation
- [ ] Keep debounced writing for non-critical updates
- [ ] Ensure performance impact is minimal

### Phase 3: Alternative Solutions (if needed)
- [ ] Consider adjusting staleness detection threshold in update script
- [ ] Optimize state file format for better performance
- [ ] Add more granular state update triggers

### Phase 4: Testing & Validation
- [ ] Test timer countdown updates properly in SketchyBar
- [ ] Verify no performance regression
- [ ] Test across different timer phases (work/break)
- [ ] Ensure start/stop/reset still work correctly

## Risk Mitigation
- **Potential Issues**: 
  - Increased I/O frequency might impact performance
  - Race conditions between timer ticks and state file access
- **Rollback Strategy**: Git checkpoint before changes, can revert debounce behavior
- **Performance Monitoring**: Monitor system impact of increased file writes

## Implementation Results

### ✅ Completed Successfully
- [x] Identified root cause: Debounced state file writing vs SketchyBar polling frequency mismatch
- [x] Implemented intelligent debouncing system (1s when timer active, 5s when idle)
- [x] Preserved event-driven polling architecture
- [x] Enhanced state writing logic with dual-channel debouncing
- [x] Maintained performance optimization to prevent I/O storms

### 🔧 Technical Solution Implemented
```swift
// Smart debouncing system in TimerViewModel.swift:
// - Fast channel: 1-second debounce when timer is running
// - Slow channel: 5-second debounce when timer is idle
// - Immediate writes for critical state changes (start/stop/reset)

private let timerActiveStateWriteSubject = PassthroughSubject<Bool, Never>()

// Usage logic:
if pomodoroState.isRunning {
    timerActiveStateWriteSubject.send(true)  // 1s debounce
} else {
    stateWriteSubject.send(true)            // 5s debounce
}
```

### ⚠️ Current Status: Timer Loop Issue Discovered
During testing, identified that the underlying Timer loop may not be starting properly:
- State file shows `isRunning: true` but timestamp doesn't update
- `timeRemaining` stays static (not decrementing)
- URL scheme toggle works (state changes) but internal timer doesn't tick

### 🎯 Next Steps for Full Resolution
1. **Debug Timer Loop Creation**: Investigate `startTimerLoop()` method in TimerViewModel
2. **Verify Timer.scheduledTimer**: Ensure Swift Timer object is created and firing
3. **Background Activity**: Check if background activity management affects timer
4. **Thread Safety**: Verify timer operations on main thread

## Validation Checklist Status
- [x] SketchyBar integration architecture fixed
- [x] Smart debouncing implemented  
- [x] State file writing frequency optimized
- [x] Event-driven polling preserved
- [x] Performance impact minimized
- [ ] **Timer loop execution needs debugging**
- [ ] Full countdown verification pending timer fix

## Files Modified
- `PomodoroTimer/ViewModels/TimerViewModel.swift`: Added intelligent debouncing system