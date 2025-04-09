//
//  BackgroundGradientModifier.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 22.04.25.
//


import SwiftUI


// MARK: Wiederverwendbarer Farbverlauf wird als Modifier aufgerufen

struct BackgroundGradientModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.9),
                        Color("darkblue").opacity(0.7),
                        Color("darkred").opacity(0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
    }
}

extension View {
    func applyBackgroundGradient() -> some View {
        self.modifier(BackgroundGradientModifier())
    }
}
