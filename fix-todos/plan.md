# TODO Resolution Plan

**Session Started**: 2025-08-04
**Total TODOs Found**: 11
**Status**: Planning Phase

## TODO Inventory by Category

### 🔒 SECURITY CRITICAL (Priority: HIGH)
1. **[SECURITY] Command injection risk**
   - **File**: `ViewModels/TimerViewModel.swift:355`
   - **Issue**: `triggerSketchyBarEvent()` takes unvalidated event parameter
   - **Risk**: High - could allow command injection
   - **Resolution**: Add input validation for event parameter

### ⚡ PERFORMANCE CRITICAL (Priority: HIGH)
2. **[PERFORMANCE] JSON file written every second**
   - **File**: `ViewModels/TimerViewModel.swift:196`
   - **Issue**: Writing JSON state file every second (3,600 times/hour)
   - **Impact**: High - unnecessary I/O load
   - **Resolution**: Implement smart change detection

3. **[PERFORMANCE] Memory allocation churn**
   - **File**: `ContentView.swift:19`
   - **Issue**: `createExperience()` called on every SwiftUI render
   - **Impact**: Medium - memory churn
   - **Resolution**: Cache experience instances with @State

4. **[PERFORMANCE] Expensive calculations on render**
   - **File**: `ContentView.swift:27`
   - **Issue**: Logarithmic math in `scaledFont()` on every render
   - **Impact**: Medium - CPU overhead
   - **Resolution**: Cache values, recalculate only on screen changes

5. **[PERFORMANCE] Main thread blocking**
   - **File**: `Services/ThemeRegistry.swift:25`
   - **Issue**: Synchronous queue access may block main thread
   - **Impact**: Medium - UI responsiveness
   - **Resolution**: Use concurrent queue with barrier pattern

6. **[PERFORMANCE] Process spawning overhead**
   - **File**: `ViewModels/TimerViewModel.swift:357`
   - **Issue**: New Process() spawned for each SketchyBar trigger
   - **Impact**: Medium - resource overhead
   - **Resolution**: Use persistent IPC mechanism

7. **[PERFORMANCE] Multiple onReceive overhead**
   - **File**: `ContentView.swift:103`
   - **Issue**: Multiple onReceive calls causing overhead
   - **Impact**: Low - minor performance impact
   - **Resolution**: Consolidate notification handling

### 🛠️ REFACTORING (Priority: MEDIUM)
8. **[ARCHITECTURE] God Object violation**
   - **File**: `ViewModels/TimerViewModel.swift:6`
   - **Issue**: Single class handling 6+ responsibilities
   - **Impact**: High - maintainability and testability
   - **Resolution**: Split into specialized controllers

9. **[REFACTOR] Redundant Combine infrastructure**
   - **File**: `ViewModels/TimerViewModel.swift:64`
   - **Issue**: Unnecessary complexity in state file writing
   - **Impact**: Low - code clarity
   - **Resolution**: Simplify immediate write pattern

### 🔧 SAFETY (Priority: MEDIUM)
10. **[SAFETY] Force unwrap risk**
    - **File**: `ViewModels/TimerViewModel.swift:309`
    - **Issue**: Potential force unwrap that could crash
    - **Impact**: Medium - app stability
    - **Resolution**: Use safe optional binding

## Resolution Order (by Risk × Impact)

### Phase 1: Critical Security & Safety (Immediate)
1. ✅ Command injection validation (`TimerViewModel.swift:355`)
2. ✅ Force unwrap safety (`TimerViewModel.swift:309`)

### Phase 2: Performance Optimizations (High Impact)
3. ✅ JSON write optimization (`TimerViewModel.swift:196`)
4. ✅ Experience caching (`ContentView.swift:19`)
5. ✅ Calculation caching (`ContentView.swift:27`)
6. ✅ Theme registry concurrency (`ThemeRegistry.swift:25`)

### Phase 3: Performance Fine-tuning (Medium Impact)
7. ✅ Process reuse (`TimerViewModel.swift:357`)
8. ✅ Notification consolidation (`ContentView.swift:103`)

### Phase 4: Architecture Improvements (Long-term)
9. ✅ God Object refactoring (`TimerViewModel.swift:6`)
10. ✅ Combine simplification (`TimerViewModel.swift:64`)

## Implementation Strategy

**Safety First**: Each TODO will be implemented with:
- Git checkpoint before changes
- Incremental commits
- Functionality verification
- Pattern matching with existing codebase

**Code Style Adherence**: 
- Follow existing SwiftUI patterns
- Match current error handling style
- Maintain architectural consistency
- Use existing logging patterns

## Progress Tracking

- **Total**: 10 TODOs
- **Completed**: 0
- **In Progress**: 0
- **Remaining**: 10

---
*Session files: This plan will be updated as TODOs are resolved*