//
//  RotatingGlobeView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 26.02.25.
//


import SwiftUI

struct GlobeView: View {
    @State private var glowIntensity: Double = 0.3
    @State private var scaleEffect: CGFloat = 0.8

    var body: some View {
        ZStack {
            // Hintergrund: Sanfter Farbverlauf für mehr Tiefe
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.5)]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            // Logo mit Glow-Effekt
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300) // Größe des Logos, passt sich an
                .shadow(color: Color.blue.opacity(glowIntensity), radius: 30) // Blauer Neon-Effekt
                .scaleEffect(scaleEffect) // Pulsierender Effekt
                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowIntensity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Füllt den gesamten Bildschirm
        .onAppear {
            glowIntensity = 2 // Glow verstärken
            scaleEffect = 1.5 // Sanfte Expansion für Puls-Effekt
        }
    }
}

// SwiftUI Preview für Vollbild
struct RotatingGlobeView_Previews: PreviewProvider {
    static var previews: some View {
        GlobeView()
            .previewDevice("iPhone 14 Pro") // Ändere das Gerät für unterschiedliche Vorschauen
    }
}




