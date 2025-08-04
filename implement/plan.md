# Implementation Plan - Gauge-Based SketchyBar Pomodoro

**Session Started**: 2025-08-04  
**Goal**: Replace time-based display with visual progress gauge to reduce JSON polling from every second to every 5-30 seconds

## Source Analysis

**Current Problem**:
- SketchyBar needs exact time (MM:SS) → requires 1-second polling
- Swift app writes JSON every second (3,600 writes/hour)
- Perfect 1:1 ratio but still high I/O load

**Proposed Solution**:
- Visual progress gauge instead of exact time
- Only need progress percentage + phase + state
- Can update every 5-30 seconds with smooth visual feedback

## Target Integration Points

### 1. SketchyBar Visual Design
**Current**: `🍅 24:59` (text-based)  
**New**: `🍅 ████████░░` (gauge-based)

**Gauge Representations**:
- **Progress Bar**: `████████░░` (8/10 blocks filled)
- **Circle Segments**: Using Unicode block characters
- **Color-coded**: Green (work), Yellow (short break), Orange (long break)

### 2. JSON Data Structure Changes
**Current JSON** (written every second):
```json
{
  "phase": "Work Session",
  "timeRemaining": 1499,
  "isRunning": true,
  "lastUpdateTimestamp": 1754287200.123
}
```

**New JSON** (written every 5-30 seconds):
```json
{
  "phase": "Work Session", 
  "progressPercent": 40.2,
  "isRunning": true,
  "totalDuration": 1500,
  "lastUpdateTimestamp": 1754287200.123,
  "sessionCount": 2
}
```

### 3. SketchyBar Script Modifications
**Polling Frequency**: 1 second → 5-30 seconds  
**Gauge Rendering**: Progress percentage → visual blocks

## Implementation Tasks

### Phase 1: Swift App JSON Optimization ✅
- [ ] Add progress percentage calculation to PomodoroState
- [ ] Modify JSON structure in TimerViewModel
- [ ] Implement smart update frequency (5-30 seconds based on context)
- [ ] Maintain backward compatibility during transition

### Phase 2: SketchyBar Gauge Rendering ✅
- [ ] Create gauge rendering function in update_state.sh
- [ ] Design visual elements (blocks, colors, icons)
- [ ] Update polling frequency in pomodoro.lua
- [ ] Test visual feedback during different phases

### Phase 3: Smart Update Strategy ✅
- [ ] **Idle/Paused**: Write only on state changes (0 polling)
- [ ] **Active Timer**: Write every 10-30 seconds
- [ ] **Phase Transitions**: Immediate write for responsiveness
- [ ] **Last Minute**: Optional 5-second updates for precision

### Phase 4: UX Enhancement ✅
- [ ] Add hover tooltip with exact time remaining
- [ ] Implement smooth visual transitions
- [ ] Add phase-specific visual cues
- [ ] Create fallback for exact time when needed

## Technical Architecture

### Swift Implementation
```swift
// PomodoroState extension
extension PomodoroState {
    var progressPercent: Double {
        let elapsed = Double(currentPhase.duration - timeRemaining)
        return (elapsed / Double(currentPhase.duration)) * 100.0
    }
}

// Smart update logic
private func shouldUpdateStateFile() -> Bool {
    let timeSinceLastWrite = Date().timeIntervalSince(lastStateWrite)
    let updateInterval: TimeInterval
    
    switch (pomodoroState.isRunning, pomodoroState.timeRemaining) {
    case (false, _): return false  // Paused - no updates
    case (true, 0...60): updateInterval = 5   // Last minute - frequent
    case (true, _): updateInterval = 15       // Normal - moderate
    }
    
    return timeSinceLastWrite >= updateInterval
}
```

### SketchyBar Gauge Rendering
```bash
# Function to render progress gauge
render_gauge() {
    local progress=$1
    local total_blocks=10
    local filled_blocks=$(( (progress * total_blocks) / 100 ))
    
    local gauge=""
    for ((i=1; i<=total_blocks; i++)); do
        if [[ $i -le $filled_blocks ]]; then
            gauge+="█"
        else
            gauge+="░"
        fi
    done
    echo "$gauge"
}
```

## Performance Impact Analysis

### Current State
- **JSON Writes**: 3,600/hour when running
- **SketchyBar Polls**: 3,600/hour when running
- **I/O Load**: High, continuous

### With Gauge Implementation
- **JSON Writes**: 120-720/hour (depends on interval)
- **SketchyBar Polls**: 120-720/hour 
- **I/O Reduction**: 80-95% less
- **Visual Quality**: Maintained with smooth progress indication

## Validation Checklist

- [ ] Gauge visual design matches system aesthetics  
- [ ] Progress accuracy within acceptable range (±2%)
- [ ] Performance improvement measured and documented
- [ ] No functionality regressions
- [ ] Smooth transitions between phases
- [ ] Fallback mechanisms for edge cases
- [ ] User testing for visual clarity

## Risk Mitigation

**Potential Issues**:
- Users might miss exact time precision
- Gauge might be unclear at small sizes
- Color accessibility concerns

**Mitigation Strategies**:
- Optional tooltip with exact time
- Test multiple gauge designs
- Ensure color-blind friendly palette
- Provide fallback to time display via configuration

## Success Metrics

- **Performance**: 80%+ reduction in JSON writes
- **UX**: Visual progress clear and intuitive
- **Compatibility**: Works with existing SketchyBar setup
- **Battery**: Measurable improvement in energy usage

---
*Session files will track implementation progress as tasks are completed*