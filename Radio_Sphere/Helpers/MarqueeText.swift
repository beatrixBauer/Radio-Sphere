//
//  MarqueeText.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 19.04.25.
//

import SwiftUI

// MARK: Animierter Stationsname in der PlayerView, falls der Name für die Anzeige zu lang ist

import SwiftUI

struct MarqueeText: View {
    let text: String
    let font: Font           // z. B. .headline oder .title
    let speed: Double        // Punkte pro Sekunde
    let delay: Double = 0    // Verzögerung bevor Animation startet
    private let delimiter = " · "
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            // ▶︎ Dynamic‑Type‑Font (skaliert, falls Nutzer „größerer Text“ aktiviert)
            let baseSize    = fontSize(for: font)
            let uiFont      = UIFontMetrics.default.scaledFont(
                                for: UIFont.systemFont(ofSize: baseSize))
            
            let boxWidth    = geo.size.width
            let textWidth   = measuredWidth(of: text, with: uiFont)
            let shouldScroll = textWidth > boxWidth          // EINZIGER Trigger
            
            if shouldScroll {
                // so oft wiederholen, bis der String > boxWidth ist
                let unit           = text + delimiter
                let unitWidth      = measuredWidth(of: unit, with: uiFont)
                let repeatCount    = Int(ceil((boxWidth + unitWidth) / unitWidth))
                let finalString    = String(repeating: unit, count: repeatCount)
                let fullWidth      = measuredWidth(of: finalString, with: uiFont)
                
                Text(finalString)
                    .font(Font(uiFont))                // SwiftUI-Font aus UIFont
                    .fixedSize()
                    .offset(x: offset)
                    .onAppear {
                        offset = 0
                        let duration = fullWidth / speed
                        withAnimation(.linear(duration: duration)
                                        .repeatForever(autoreverses: false)
                                        .delay(delay)) {
                            offset = -fullWidth + boxWidth
                        }
                    }
                    .frame(width: boxWidth,
                           height: uiFont.lineHeight,
                           alignment: .leading)
            } else {
                Text(text)
                    .font(Font(uiFont))
                    .frame(width: boxWidth,
                           height: uiFont.lineHeight,
                           alignment: .center)
            }
        }
        .clipped()
        .frame(height: fontSize(for: font) * 1.2)   // grobe Zeilenhöhe
    }
    
    // MARK: - Hilfsfunktionen
    private func measuredWidth(of string: String, with font: UIFont) -> CGFloat {
        (string as NSString).size(withAttributes: [.font: font]).width
    }
    
    /// Liefert die Basis‑Punktgröße eines Font‑Styles (ohne Dynamic‑Type‑Skalierung)
    private func fontSize(for font: Font) -> CGFloat {
        switch font {
        case .largeTitle: return 34
        case .title:      return 28
        case .title2:     return 22
        case .title3:     return 20
        case .headline:   return 17
        case .subheadline:return 15
        case .caption:    return 13
        default:          return 17
        }
    }
}


/*struct MarqueeText: View {
    let text: String
    let font: Font
    let speed: Double      // Geschwindigkeit des Marquees
    let delay: Double = 0.0  // Verzögerung vor Start
    let threshold: Int      // Zeichen-Länge für Scroll-Trigger
    let delimiter = " · "
    let repeatCount = 10     // Wiederholungen

    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let containerWidth = geo.size.width
            let uiFont = UIFont.systemFont(ofSize: fontSize(for: font))
           // let measuredTextWidth = textWidth(text: text, font: uiFont)

            // Scrollen, wenn Text länger als threshold Zeichen
            let shouldScroll = text.count > threshold
            
            if shouldScroll {
                let source = text + delimiter
                let repeatedText = String(repeating: source, count: repeatCount)
                let totalWidth = textWidth(text: repeatedText, font: uiFont)

                HStack(spacing: 0) {
                    Text(repeatedText)
                        .font(font)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .offset(x: offset)
                .onAppear {
                    offset = 0
                    let duration = totalWidth / speed
                    withAnimation(
                        Animation.linear(duration: duration)
                            .repeatForever(autoreverses: false)
                            .delay(delay)
                    ) {
                        offset = -totalWidth
                    }
                }
                .frame(width: containerWidth, height: uiFont.lineHeight, alignment: .leading)
            } else {
                Text(text)
                    .font(font)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(width: containerWidth, alignment: .center)
            }
        }
        .clipped()
    }

    private func textWidth(text: String, font: UIFont) -> CGFloat {
        let attrs = [NSAttributedString.Key.font: font]
        return text.size(withAttributes: attrs).width
    }

    private func fontSize(for font: Font) -> CGFloat {
        switch font {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        default: return 20
        }
    }
}*/

/*struct MarqueeText: View {
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
}*/

