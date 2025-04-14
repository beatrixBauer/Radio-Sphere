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
    let speed: Double      // Geschwindigkeit in Punkte pro Sekunde, z. B. 30.0
    let delimiter = "·"
    let repeatCount = 10   

    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            // Erstelle den Einzeltext inklusive Delimiter
            let marqueeText = text + " " + delimiter + " "
            // Berechne die Breite des Einzeltexts
            let uiFont = UIFont.systemFont(ofSize: fontSize(for: font))
            let singleTextWidth = self.textWidth(text: marqueeText, font: uiFont)
            // Gesamtbreite ist der Einzeltext multipliziert mit der Anzahl der Wiederholungen
            let totalWidth = singleTextWidth * CGFloat(repeatCount)
            
            HStack(spacing: 0) {
                ForEach(0..<repeatCount, id: \.self) { _ in
                    Text(marqueeText)
                        .font(font)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .offset(x: offset)
            .onAppear {
                offset = 0
                // Berechne die Animationsdauer anhand der Gesamtbreite und der Geschwindigkeit
                let duration = Double(totalWidth) / speed
                withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
                    offset = -totalWidth
                }
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
        // Hier kannst du eine Umrechnung vornehmen oder einen Standardwert festlegen.
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
