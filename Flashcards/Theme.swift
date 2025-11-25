import SwiftUI

enum AppTheme {
    // Core palette tuned for both light and dark
    static let accent = Color(red: 0.29, green: 0.42, blue: 0.75)
    static let accentSoft = Color(red: 0.29, green: 0.42, blue: 0.75).opacity(0.12)
    static let surfaceLight = Color(red: 0.97, green: 0.98, blue: 1.0)
    static let surfaceDark = Color(red: 0.12, green: 0.13, blue: 0.16)

    static func background(for scheme: ColorScheme) -> LinearGradient {
        let top = scheme == .dark ? Color(red: 0.08, green: 0.1, blue: 0.13) : Color(red: 0.94, green: 0.96, blue: 0.99)
        let bottom = scheme == .dark ? Color(red: 0.03, green: 0.04, blue: 0.08) : Color.white
        return LinearGradient(colors: [top, bottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func cardBackground(for scheme: ColorScheme) -> some ShapeStyle {
        let base = scheme == .dark ? surfaceDark : surfaceLight
        return LinearGradient(colors: [base, base.opacity(0.92)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct CapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(AppTheme.accent.opacity(configuration.isPressed ? 0.75 : 1), in: Capsule())
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.15), radius: configuration.isPressed ? 4 : 8, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct SubtleCard: ViewModifier {
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(AppTheme.cardBackground(for: scheme), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.accent.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: .black.opacity(scheme == .dark ? 0.35 : 0.1), radius: 18, x: 0, y: 12)
    }
}

extension View {
    func subtleCard() -> some View { modifier(SubtleCard()) }
}
