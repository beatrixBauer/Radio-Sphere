//
//  ActionButton.swift
//  Radio_Sphere

import SwiftUI

// MARK: Definiert wiederverwendbaren Button, der beim Tippen kurz die Farbe wechselt
// Verwendung in der PlayerView für next und previous Station

struct ActionButton: View {
    let systemName: String
    let action: () -> Void
    let buttonSize: CGFloat
    let identifier: String?

    @State private var isPressed: Bool = false

    // buttonSize als Parameter
    init(systemName: String, buttonSize: CGFloat = 30, identifier: String? = nil, action: @escaping () -> Void) {
        self.systemName = systemName
        self.buttonSize = buttonSize
        self.identifier = identifier
        self.action = action
        
    }

    var body: some View {
        Button(action: {
            isPressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
        }) {
            Image(systemName: systemName)
                .resizable()
                .frame(width: buttonSize, height: buttonSize)
                .foregroundColor(isPressed ? Color("goldorange") : .gray)
                .shadow(radius: 4)
                .animation(nil, value: isPressed)
        }
        .buttonStyle(.plain)
    }
}
