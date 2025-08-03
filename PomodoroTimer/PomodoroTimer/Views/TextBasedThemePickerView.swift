import SwiftUI

/// nnn/yazi-inspired theme picker with keyboard navigation
struct TextBasedThemePickerView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @ObservedObject private var themeRegistry = ThemeRegistry.shared
    
    var body: some View {
        ZStack {
            backgroundView
            mainPickerContainer
        }
        .onAppear {
            initializeHighlightedTheme()
        }
    }
    
    private var backgroundView: some View {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
    }
    
    private var mainPickerContainer: some View {
        VStack(spacing: 0) {
            themeListView
            statusLineView
        }
        .background(Color.black.opacity(0.9))
        .cornerRadius(8)
        .frame(maxWidth: 400, maxHeight: 300)
    }
    
    private var themeListView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(themeRegistry.availableThemes.enumerated()), id: \.element.id) { index, theme in
                ThemeRowView(
                    theme: theme,
                    index: index,
                    isSelected: viewModel.highlightedThemeIndex == index
                )
            }
        }
        .padding(.vertical, 16)
    }
    
    private var statusLineView: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray)
            
            HStack {
                themeInfoText
                Spacer()
                controlsHintText
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    private var themeInfoText: some View {
        Group {
            if let highlightedTheme = viewModel.highlightedTheme {
                Text("Theme \(viewModel.highlightedThemeIndex + 1)/\(themeRegistry.availableThemes.count): \(highlightedTheme.displayName)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var controlsHintText: some View {
        Text("↑/↓ navigate, Enter select, Esc cancel")
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(.gray)
    }
    
    private func initializeHighlightedTheme() {
        if let currentIndex = themeRegistry.availableThemes.firstIndex(where: { $0.id == viewModel.currentTheme.id }) {
            viewModel.setHighlightedThemeIndex(currentIndex)
        }
    }
}

struct ThemeRowView: View {
    let theme: AnyTheme
    let index: Int
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            selectionIndicator
            themeName
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(rowBackground)
    }
    
    private var selectionIndicator: some View {
        Text(isSelected ? ">" : " ")
            .font(.system(size: 14, design: .monospaced))
            .foregroundColor(.white)
            .frame(width: 16, alignment: .leading)
    }
    
    private var themeName: some View {
        Text(theme.displayName)
            .font(.system(size: 14, design: .monospaced))
            .foregroundColor(isSelected ? .white : .gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var rowBackground: some View {
        Rectangle()
            .fill(isSelected ? Color.white.opacity(0.1) : Color.clear)
    }
}

#Preview {
    TextBasedThemePickerView()
        .environmentObject(TimerViewModel())
}
