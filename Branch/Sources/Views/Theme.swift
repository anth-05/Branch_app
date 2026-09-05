import SwiftUI

enum Theme {
    static let accent = Color(red: 0.42, green: 0.88, blue: 0.45)
    static let background = Color(red: 0.04, green: 0.04, blue: 0.045)
    static let card = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let cardSecondary = Color(red: 0.16, green: 0.16, blue: 0.17)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.55)
    static let cornerRadius: CGFloat = 22
}

struct CardBackground: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }
}

extension View {
    func brandCard(padding: CGFloat = 16) -> some View {
        modifier(CardBackground(padding: padding))
    }
}
