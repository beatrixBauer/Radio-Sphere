//
//  MarqueeText.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 19.03.25.
//

/// Animierter Stationsname in der PlayerView, falls der Name für die Anzeige zu lang ist

import SwiftUI

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
                        let textWidth = textWidth(text: text, font: UIFont.systemFont(ofSize: 17))
                        let containerWidth = geometry.size.width

                        if textWidth > containerWidth {
                            offset = containerWidth / 2  // Startposition mittig setzen
                            withAnimation(Animation.linear(duration: speed * 1.5).repeatForever(autoreverses: true).delay(delay)) {
                                offset = -textWidth/2 // Verschiebung nach links
                            }
                        }
                    }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
        .frame(height: 25)
        .clipped()
        .padding(.leading, 10)
    }
    
    private func textWidth(text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let size = text.size(withAttributes: attributes)
        return size.width
    }
}




