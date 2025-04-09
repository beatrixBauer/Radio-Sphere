import SwiftUI

struct ActiveRowBackgroundModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if isActive {
                        // Hervorhebung, wenn die Zeile aktiv ist
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.05)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        // Standardhintergrund (transparent)
                        Color.clear
                    }
                }
            )
    }
}

extension View {
    func activeRowBackground(isActive: Bool) -> some View {
        self.modifier(ActiveRowBackgroundModifier(isActive: isActive))
    }
}
