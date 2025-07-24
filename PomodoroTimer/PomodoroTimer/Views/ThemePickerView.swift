import SwiftUI

/// Compact theme selection interface with smooth transitions
struct ThemePickerView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            // Gear icon button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(viewModel.currentTheme.buttonTextColor.opacity(0.8))
                    .frame(width: 32, height: 32)
                    .background(viewModel.currentTheme.secondaryButtonColor.opacity(0.7))
                    .clipShape(Circle())
                    .scaleEffect(isExpanded ? 1.1 : 1.0)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            }
            .buttonStyle(CircleHoverButtonStyle(theme: viewModel.currentTheme))
            
            // Theme selection panel
            if isExpanded {
                VStack(alignment: .trailing, spacing: 8) {
                    ForEach(Theme.allCases) { theme in
                        ThemeOption(
                            theme: theme,
                            isSelected: viewModel.currentTheme == theme,
                            onSelect: {
                                viewModel.setTheme(theme)
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isExpanded = false
                                }
                            }
                        )
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.nordNight1.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(.top, 16)
        .padding(.trailing, 16)
        .onTapGesture {
            // Close panel when tapping outside
            if isExpanded {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded = false
                }
            }
        }
    }
}

/// Individual theme selection option
struct ThemeOption: View {
    let theme: Theme
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Theme icon
                Image(systemName: theme.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? theme.accentColor : .nordSecondary)
                    .frame(width: 20, height: 20)
                
                // Theme name and description
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.displayName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? theme.accentColor : .nordPrimary)
                    
                    Text(theme.description)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.nordSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Circle()
                        .fill(theme.accentColor)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? theme.accentColor.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? theme.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .frame(width: 220) // Fixed width for consistency
    }
}

/// Theme preview thumbnail (for future enhancement)

#Preview {
    ThemePickerView()
        .frame(width: 400, height: 400)
        .background(Color.black.opacity(0.8))
        .environmentObject(TimerViewModel())
}