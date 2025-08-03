import SwiftUI
import AppKit
import ApplicationServices

struct PermissionView: View {
    let onDismiss: () -> Void
    @State private var showPermissionError = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon and title
            VStack(spacing: 12) {
                Image(systemName: "key.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.nordAccent)
                
                Text("Accessibility Permission Required")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.nordPrimary)
            }
            
            // Explanation
            VStack(spacing: 16) {
                Text("To use the global hotkey **⌃⌥P** to toggle your timer from anywhere on your Mac, Pomodoro Timer needs Accessibility permissions.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.nordSecondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "1.circle.fill")
                            .foregroundColor(.nordAccent)
                        Text("Click **Open System Settings** below")
                    }
                    
                    HStack {
                        Image(systemName: "2.circle.fill")
                            .foregroundColor(.nordAccent)
                        Text("Find **Pomodoro Timer** in the list")
                    }
                    
                    HStack {
                        Image(systemName: "3.circle.fill")
                            .foregroundColor(.nordAccent)
                        Text("Toggle the switch to **enable** access")
                    }
                    
                    HStack {
                        Image(systemName: "4.circle.fill")
                            .foregroundColor(.nordAccent)
                        Text("Return to this app and click **Done**")
                    }
                }
                .font(.body)
                .foregroundColor(.nordSecondary)
            }
            
            // Error message if permissions not granted
            if showPermissionError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Accessibility permission not detected. Please ensure Pomodoro Timer is enabled in System Settings.")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal)
                .transition(.opacity)
            }
            
            // Buttons
            VStack(spacing: 12) {
                Button("Done") {
                    checkPermissionsAndDismiss()
                }
                .buttonStyle(CircleHoverButtonStyle())
                .controlSize(.large)
                
                Button("Open System Settings") {
                    openAccessibilitySettings()
                    showPermissionError = false // Hide error when opening settings
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button("Skip (No Global Hotkey)") {
                    onDismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.nordSecondary)
            }
            
            // Footer note
            Text("You can enable this later in the app menu.")
                .font(.caption)
                .foregroundColor(.nordMuted)
        }
        .padding(32)
        .frame(width: 480)
        .background {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
        }
    }
    
    private func checkPermissionsAndDismiss() {
        // Check if accessibility permissions are now granted
        if AXIsProcessTrusted() {
            Logger.permission("✅ Accessibility permissions confirmed - dismissing permission dialog")
            onDismiss()
        } else {
            Logger.permission("❌ Accessibility permissions still not granted")
            withAnimation(.easeInOut(duration: 0.3)) {
                showPermissionError = true
            }
            
            // Hide error message after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showPermissionError = false
                }
            }
        }
    }
    
    private func openAccessibilitySettings() {
        // Open System Settings directly to Accessibility pane
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        } else {
            // Fallback: open general Privacy & Security pane
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}

#Preview {
    PermissionView {
        Logger.debug("Permission view dismissed (preview)", category: .ui)
    }
    .preferredColorScheme(.dark)
}
