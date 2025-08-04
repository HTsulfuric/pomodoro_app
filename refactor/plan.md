# Refactor Plan - Debounce Code Cleanup
**Session Started:** 2025-08-04 10:17
**Target:** TimerViewModel.swift - Remove unnecessary debounce-related code

## Initial State Analysis
- **Current Architecture**: TimerViewModel uses two PassthroughSubjects for state file writing (originally for different debounce timings)
- **Problem Areas**: Debouncing was removed but infrastructure remains, creating unnecessary complexity
- **Dependencies**: Combine framework for subjects, but usage can be simplified
- **Test Coverage**: Manual testing confirmed JSON writes are immediate and responsive

## Code Analysis
**Files affected:**
- `PomodoroTimer/ViewModels/TimerViewModel.swift` (lines 22-23, 39, 59, 61-72, 77-84, 199)

**Current unnecessary complexity:**
1. Two separate subjects doing identical work: `stateWriteSubject` and `timerActiveStateWriteSubject` 
2. Method named `setupDebouncedStateFileWriter` when no debouncing occurs
3. Misleading comments referencing debouncing and timing delays
4. Branching logic in `scheduleStateFileWrite` that's no longer needed
5. Comments on line 199 mentioning "debounced" writes

## Refactoring Tasks

### Task 1: Consolidate Subjects (Risk: Low)
- **Action**: Replace two subjects with single `stateWriteSubject`
- **Files**: TimerViewModel.swift lines 22-23, 61-72
- **Rationale**: Both subjects now perform identical immediate writes

### Task 2: Rename Methods and Update Comments (Risk: Low)
- **Action**: Rename `setupDebouncedStateFileWriter` → `setupImmediateStateFileWriter`  
- **Action**: Update method call on line 39
- **Action**: Update all comments to reflect immediate writing

### Task 3: Simplify scheduleStateFileWrite Logic (Risk: Low)
- **Action**: Remove branching logic since both paths are now identical
- **Files**: TimerViewModel.swift lines 77-84
- **Rationale**: `immediate` parameter can be removed or simplified

### Task 4: Update Documentation Comments (Risk: Low)
- **Action**: Remove references to "debouncing", "I/O storms", timing delays
- **Action**: Update method documentation to reflect immediate behavior

## Validation Checklist
- [ ] App builds successfully
- [ ] Timer functionality unchanged (start/pause/reset/skip)
- [ ] JSON state file still updates immediately  
- [ ] Menu bar controls work correctly
- [ ] URL schemes still functional
- [ ] No broken imports or references
- [ ] All old debounce terminology removed
- [ ] Comments accurately reflect current behavior

## Risk Assessment
**Overall Risk: LOW** - Changes are primarily cosmetic/structural
- No behavioral changes to timer logic
- JSON writing behavior remains identical
- All external interfaces unchanged

## Rollback Strategy
- Git commit before starting refactoring
- Keep backup of original file content
- Each task can be individually reverted if needed

## Expected Benefits
- **Code Clarity**: Method names match actual behavior
- **Reduced Complexity**: Single subject instead of two
- **Maintenance**: Comments accurately describe current implementation
- **Performance**: Slight reduction in memory usage (one fewer subject)