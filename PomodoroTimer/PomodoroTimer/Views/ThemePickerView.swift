import SwiftUI

/// nnn/yazi-style keyboard-only theme picker (visual picker removed for authenticity)
struct ThemePickerView: View {
    @EnvironmentObject var viewModel: TimerViewModel
    
    var body: some View {
        // For maximum nnn/yazi authenticity, theme selection is keyboard-only
        // Use T key when overlay is visible to open text-based theme picker
        EmptyView()
    }
}


#Preview {
    ThemePickerView()
        .frame(width: 400, height: 400)
        .background(Color.black.opacity(0.8))
        .environmentObject(TimerViewModel())
}