//
//  ActiveRowBackgroundModifier.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 09.04.25.
//


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
                            gradient: Gradient(colors: [
                                Color.darkblue.opacity(0.2),
                                Color.midblue.opacity(0.4),
                                Color.darkblue.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
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
