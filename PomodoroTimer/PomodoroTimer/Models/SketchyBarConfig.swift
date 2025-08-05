import Foundation

// MARK: - SketchyBar Configuration Model

// Simple enable/disable toggle for SketchyBar integration

struct SketchyBarConfig: Codable, Equatable {
    // MARK: - Main Toggle

    var isEnabled: Bool = false // Default to disabled to avoid unnecessary I/O

    // MARK: - Basic Settings (only used when enabled)

    var updateInterval: Double = 15.0 // Seconds between updates
    var stateFilePath: String = "~/.config/pomodoro-timer/state.json"
    var sketchyBarPath: String = "/opt/homebrew/bin/sketchybar"

    // MARK: - Default Configuration

    static let `default` = SketchyBarConfig()

    // MARK: - Computed Properties

    var expandedStateFilePath: String {
        NSString(string: stateFilePath).expandingTildeInPath
    }
}

// MARK: - Configuration Persistence

extension SketchyBarConfig {
    private static let configFileURL: URL = {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let configDir = homeDir.appendingPathComponent(".config/pomodoro-timer")
        return configDir.appendingPathComponent("sketchybar-config.json")
    }()

    // MARK: - Load Configuration

    static func load() -> SketchyBarConfig {
        guard FileManager.default.fileExists(atPath: configFileURL.path) else {
            let defaultConfig = SketchyBarConfig.default
            defaultConfig.save()
            return defaultConfig
        }

        do {
            let data = try Data(contentsOf: configFileURL)
            let config = try JSONDecoder().decode(SketchyBarConfig.self, from: data)
            return config
        } catch {
            print("Failed to load SketchyBar config: \(error)")
            return SketchyBarConfig.default
        }
    }

    // MARK: - Save Configuration

    func save() {
        let directory = Self.configFileURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            try data.write(to: Self.configFileURL)
        } catch {
            print("Failed to save SketchyBar config: \(error)")
        }
    }

    // MARK: - Validation

    func isValid() -> (Bool, [String]) {
        var errors: [String] = []

        if updateInterval < 1.0 || updateInterval > 300.0 {
            errors.append("Update interval must be between 1-300 seconds")
        }

        if isEnabled, !FileManager.default.fileExists(atPath: NSString(string: sketchyBarPath).expandingTildeInPath) {
            errors.append("SketchyBar executable not found at: \(sketchyBarPath)")
        }

        return (errors.isEmpty, errors)
    }
}
