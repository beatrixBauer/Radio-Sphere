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
    let speed: Double      // Geschwindigkeit des Marquees
    let delay: Double = 0.0  // Optionale Verzögerung für den Start der Animation
    let delimiter = "·"
    let repeatCount = 10   // Anzahl Wiederholungen, falls animiert wird

    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            // Mit UIFont lassen sich Textmaße besser berechnen
            let uiFont = UIFont.systemFont(ofSize: fontSize(for: font))
            let containerWidth = geometry.size.width
            let measuredTextWidth = self.textWidth(text: text, font: uiFont)

            if measuredTextWidth > containerWidth {
                // Text passt nicht komplett – Marquee-Effekt soll starten.
                // Erstelle eine wiederholte Zeichenkette: [Text + delimiter]
                let marqueeText = text + " " + delimiter + " "
                let repeatedText = String(repeating: marqueeText, count: repeatCount)
                let totalWidth = self.textWidth(text: repeatedText, font: uiFont)
                
                HStack(spacing: 0) {
                    Text(repeatedText)
                        .font(font)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .offset(x: offset)
                .onAppear {
                    offset = 0
                    let duration = Double(totalWidth) / speed
                    withAnimation(Animation.linear(duration: duration)
                                    .repeatForever(autoreverses: false)
                                    .delay(delay)) {
                        offset = -totalWidth
                    }
                }
            } else {
                // Text passt komplett – Animation nicht nötig.
                Text(text)
                    .font(font)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(width: containerWidth, alignment: .center)
            }
        }
        .frame(height: 40)
        .clipped()
        .padding(.leading, 10)
    }
    
    private func textWidth(text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return text.size(withAttributes: attributes).width
    }
    
    private func fontSize(for font: Font) -> CGFloat {
        // Hier kannst du den Fontsize-Wert anpassen, falls nötig.
        return 20
    }
}



/*struct MarqueeText: View {
    let text: String
    let font: Font
    let speed: Double
    let delay: Double
    let delimiter = "·"

    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let marqueeText = text + " " + delimiter + " "
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
}*/
