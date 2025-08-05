import SwiftUI

/// Simple SketchyBar enable/disable toggle popup
struct SketchyBarSettingsPopupView: View {
    @State private var config: SketchyBarConfig = .load()

    private let title = "SketchyBar Integration"

    var body: some View {
        ZStack {
            backgroundView
            mainToggleContainer
        }
        .onReceive(NotificationCenter.default.publisher(for: .sketchyBarSettingsKeyPress)) { notification in
            if let keyCode = notification.userInfo?["keyCode"] as? UInt16 {
                handleKeyPress(keyCode)
            }
        }
    }

    private var backgroundView: some View {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
    }

    private var mainToggleContainer: some View {
        VStack(spacing: 16) {
            headerView
            toggleView
            statusLineView
        }
        .padding(24)
        .background(Color.black.opacity(0.9))
        .cornerRadius(8)
        .frame(maxWidth: 400)
    }

    private var headerView: some View {
        Text(title)
            .font(.system(size: 16, design: .monospaced))
            .foregroundColor(.white)
            .fontWeight(.bold)
    }

    private var toggleView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Enable SketchyBar Integration:")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.gray)
                Spacer()
                Text(config.isEnabled ? "ON" : "OFF")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(config.isEnabled ? .green : .red)
                    .fontWeight(.bold)
            }

            if !config.isEnabled {
                Text("Disables all SketchyBar I/O operations")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            } else {
                Text("Enables JSON state file updates for SketchyBar")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var statusLineView: some View {
        Text("Space to toggle, Enter to save, Esc to cancel")
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(.gray)
    }

    // MARK: - Helper Methods

    private func toggleEnabled() {
        config.isEnabled.toggle()
    }

    private func saveAndClose() {
        config.save()
        // Notify IntegrationController of configuration changes
        NotificationCenter.default.post(name: .sketchyBarConfigChanged, object: config)
        // Close the popup
        NotificationCenter.default.post(name: .hideSketchyBarSettings, object: nil)
    }

    // MARK: - Keyboard Navigation

    func handleKeyPress(_ keyCode: UInt16) {
        switch keyCode {
        case 49: // Space
            toggleEnabled()
        case 36: // Enter
            saveAndClose()
        case 53: // ESC
            NotificationCenter.default.post(name: .hideSketchyBarSettings, object: nil)
        default:
            break
        }
    }
}

// MARK: - Notification Extension

extension Notification.Name {
    static let hideSketchyBarSettings = Notification.Name("hideSketchyBarSettings")
    static let sketchyBarConfigChanged = Notification.Name("sketchyBarConfigChanged")
}

#Preview {
    SketchyBarSettingsPopupView()
}
