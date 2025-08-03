# Security Policy

## Privacy-First Architecture

The Pomodoro Timer app is designed with **privacy and security as core principles**. We believe productivity tools should enhance your workflow without compromising your privacy.

## No Invasive Permissions Required

### What We DON'T Access
- ❌ **Keystroke Logging**: No global keyboard monitoring or keystroke capture
- ❌ **Accessibility API**: No invasive system access permissions required
- ❌ **Screen Recording**: No screenshot or screen content access
- ❌ **File System**: No access to personal files or documents
- ❌ **Network Access**: No internet connectivity or data transmission
- ❌ **Location Services**: No GPS or location tracking
- ❌ **Camera/Microphone**: No audio or video recording capabilities
- ❌ **Personal Data**: No contact lists, calendars, or personal information access

### What We DO Access (Minimal & Standard)
- ✅ **Notifications**: Standard macOS UserNotifications.framework for timer alerts
- ✅ **Menu Bar**: NSStatusItem for app controls (standard for menu bar apps)
- ✅ **Local Storage**: UserDefaults for app preferences (sandboxed)
- ✅ **System Audio**: NSSound for timer completion sounds (standard system sounds)

## Technical Security Measures

### Privacy-Safe Implementations

#### 1. Keyboard Input Management
```swift
// ❌ AVOIDED: Global key monitoring (privacy violation)
NSEvent.addGlobalMonitorForEvents(matching: .keyDown) // NOT USED

// ✅ IMPLEMENTED: Privacy-safe local monitoring
NSEvent.addLocalMonitorForEvents(matching: .keyDown)  // App-focused only

// ✅ IMPLEMENTED: Carbon Event Manager for global hotkey
RegisterEventHotKey() // Single hotkey, no keystroke capture
```

#### 2. System Integration
```swift
// ❌ AVOIDED: Accessibility API (invasive permissions)
AXIsProcessTrusted() // NOT USED

// ✅ IMPLEMENTED: Standard system APIs
NSStatusBar.system.statusItem() // Menu bar integration
UNUserNotificationCenter.current() // Standard notifications
```

#### 3. Data Storage
```swift
// ✅ All data stored locally in sandboxed locations
UserDefaults.standard // App preferences
~/.config/pomodoro-timer/state.json // Timer state (local only)
```

### Network Security
- **No Network Access**: App functions entirely offline
- **No Data Transmission**: Zero external network requests
- **No Telemetry**: No usage analytics or crash reporting to external servers
- **No Updates**: No automatic update mechanism (manual App Store/GitHub only)

## System Permissions

### Required Permissions
1. **Notifications** (Standard)
   - **Purpose**: Timer completion alerts
   - **Scope**: App-specific notifications only
   - **User Control**: Can be disabled in System Preferences
   - **Implementation**: Standard UNUserNotificationCenter

### No Additional Permissions
- **No Accessibility Access**: App works without accessibility permissions
- **No Full Disk Access**: No file system access beyond sandbox
- **No Screen Recording**: No screen capture capabilities
- **No Automation**: No AppleScript or system automation access

## Data Privacy

### What Data We Store
- **Timer Settings**: Work/break durations, session counts
- **Theme Preferences**: Selected theme and customizations  
- **Window Position**: Overlay window position (local only)
- **Session Statistics**: Daily session counts (local only, no history)

### What Data We DON'T Store
- **Keystroke Data**: No keyboard input capture or logging
- **Screen Content**: No screenshots or screen recording
- **Personal Information**: No names, emails, or contact data
- **Usage Patterns**: No detailed activity tracking
- **App Usage**: No which apps you use during sessions

### Data Location
All data stored in standard macOS sandbox locations:
- `~/Library/Preferences/com.local.PomodoroTimer.plist` (app preferences)
- `~/.config/pomodoro-timer/state.json` (timer state for SketchyBar)

### Data Retention
- **Session Data**: Resets daily automatically
- **Preferences**: Persist until manually deleted
- **No Cloud Sync**: All data remains on local device

## External Integrations

### SketchyBar Integration (Optional)
- **Purpose**: Display timer in menu bar
- **Data Shared**: Timer state only (time remaining, current phase)
- **Method**: Local JSON file, no network transmission
- **User Control**: Completely optional, can be disabled

### URL Scheme Support
- **Purpose**: External control (automation, Alfred, etc.)
- **Supported Commands**: `toggle`, `reset`, `skip`, `show-app`
- **Security**: Standard macOS URL scheme handling, no sensitive data exposure
- **Example**: `open "pomodoro://toggle"`

## Threat Model

### What We Protect Against
1. **Privacy Violations**: No keystroke logging or screen monitoring
2. **Data Exfiltration**: No network access prevents data transmission
3. **Permission Escalation**: Minimal permissions prevent system compromise
4. **Surveillance**: No detailed activity tracking or monitoring

### Security Boundaries
- **Sandboxed Execution**: Standard macOS app sandbox
- **Local-Only Data**: No cloud storage or transmission
- **Standard APIs**: Only documented, approved system APIs
- **User Consent**: All features clearly explained and optional

## Code Security

### Static Analysis
- **No Suspicious APIs**: Code review confirms no privacy-violating functions
- **Minimal Dependencies**: Few external libraries reduce attack surface
- **Open Source**: Full source code available for security audit

### Runtime Security
- **Memory Safety**: Swift memory management prevents buffer overflows
- **Type Safety**: Strong typing prevents injection attacks
- **Exception Handling**: Graceful error handling prevents crashes

## Security Updates

### Vulnerability Reporting
If you discover a security vulnerability:
1. **DO NOT** create a public GitHub issue
2. **Email**: Report privately to maintainers
3. **Include**: Detailed description and reproduction steps
4. **Response**: We will respond within 48 hours

### Update Policy
- **Critical Security Fixes**: Immediate release
- **Security Improvements**: Included in regular updates
- **Transparency**: Security-related changes documented in CHANGELOG.md

## Compliance & Standards

### Industry Standards
- **OWASP Mobile Security**: Follows mobile app security guidelines
- **Apple Security Guidelines**: Adheres to macOS security best practices
- **Privacy by Design**: Built with privacy as fundamental requirement

### Regional Compliance
- **GDPR**: No personal data collection, processing, or transmission
- **CCPA**: No sale or sharing of personal information
- **Privacy Laws**: Compliant with major privacy regulations due to no-data-collection design

## User Controls

### Privacy Controls
- **Notification Permissions**: Can be revoked in System Preferences
- **SketchyBar Integration**: Completely optional
- **Data Deletion**: Delete preferences to remove all app data
- **Network Isolation**: No network access to control

### Transparency Features
- **Open Source**: Full code available for audit
- **Documentation**: Complete privacy policy and technical details
- **No Hidden Features**: All functionality clearly documented

## Verification

### How to Verify Our Claims
1. **Network Monitoring**: Use tools like Little Snitch to confirm no network access
2. **Permission Audit**: Check System Preferences → Privacy to see minimal permissions
3. **Code Review**: Examine source code for privacy-violating functions
4. **File System**: Monitor file access to confirm local-only storage

### Security Audit Results
- **Last Security Review**: 2025-08-03
- **Findings**: No privacy violations or security issues identified
- **Tools Used**: Static analysis, runtime monitoring, manual code review

---

## Summary

The Pomodoro Timer app demonstrates that **productivity software can be both powerful and privacy-respecting**. By using privacy-safe APIs and avoiding invasive system access, we provide full functionality without compromising user privacy.

**Key Principle**: If we don't need access to your data to help you be productive, we don't ask for it.

---

**Security Contact**: For security-related inquiries, please follow responsible disclosure practices and contact maintainers privately before public disclosure.