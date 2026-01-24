import SwiftUI

struct DashCardStyle<S: InsettableShape>: ViewModifier {
    let shape: S

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color.white)
            .clipShape(shape)
            .overlay(
                shape
                    .strokeBorder(
                        colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.08),
                radius: 16,
                x: 0,
                y: 10
            )
    }
}

extension View {
    func dashCardStyle<S: InsettableShape>(_ shape: S) -> some View {
        modifier(DashCardStyle(shape: shape))
    }
}
