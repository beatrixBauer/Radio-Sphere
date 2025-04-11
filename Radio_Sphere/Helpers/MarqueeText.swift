//
//  MarqueeText.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 19.04.25.
//

import SwiftUI

// MARK: Animierter Stationsname in der PlayerView, falls der Name für die Anzeige zu lang ist

struct MarqueeText: View {
    let text: String
    let font: Font
    let speed: Double
    let delay: Double

    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Text(text)
                    .font(font)
                    .fixedSize(horizontal: true, vertical: false)
                    .offset(x: offset)
                    .onAppear {
                        // Verwendung von UIFont, damit anhand der Schriftart berechnet werden kann, wieiel Platz der Titel einnimmt
                        let uiFont = UIFont.preferredFont(forTextStyle: .title1)
                        let measuredTextWidth = self.textWidth(text: text, font: uiFont)
                        let containerWidth = geometry.size.width

                        if measuredTextWidth > containerWidth * 0.95 {
                            offset = containerWidth / 2  // Startposition mittig setzen
                            withAnimation(Animation.linear(duration: speed * 1.5)
                                            .repeatForever(autoreverses: true)
                                            .delay(delay)) {
                                offset = -measuredTextWidth / 2 // Verschiebung nach links
                            }
                        }
                    }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
        .frame(height: 40)
        .clipped()
        .padding(.leading, 10)
    }

    private func textWidth(text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return text.size(withAttributes: attributes).width
    }
}
