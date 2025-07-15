//
//  GlobeView.swift
//  Radio_Sphere
//

// MARK: Startanimation Globus

import SwiftUI

struct GlobeView: View {
    @State private var glowIntensity: Double = 0.3
    @State private var scaleEffect: CGFloat = 0.7
    @State private var glowCount = 0
    @State private var showText: Bool = false // Steuert die Einblendung des Namens

    var body: some View {
        ZStack {
            // Hintergrund mit Farbverlauf
            RadialGradient(
                gradient: Gradient(colors: [Color("darkblue"), Color.black.opacity(0.9)]),
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) { // Abstand zwischen Logo & Text für Stabilität
                // Logo mit Glow-Effekt
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .shadow(color: Color.blue.opacity(glowIntensity), radius: 30)
                    .scaleEffect(scaleEffect) // Skalierung
                    .onAppear {
                        startScalingAnimation()
                        glowAnimationLoop()
                    }

                // Name "Radio Sphere" erscheint nach der Animation
                Text("Radio Sphere")
                    .font(.custom("Exo-BoldItalic", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: Color.blue.opacity(0.8), radius: 10)
                    .opacity(showText ? 1 : 0) // Einblendung steuern
                    .animation(.easeIn(duration: 1.5), value: showText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // Skalierung einmalig: 0.7 → 1.5 → 1.0
    private func startScalingAnimation() {
        withAnimation(.easeInOut(duration: 1.5)) {
            scaleEffect = 1.5
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 1.5)) {
                scaleEffect = 1.0
            }

            // Text erscheint nach abgeschlossener Skalierung
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showText = true
            }
        }
    }

    // Glow-Effekt dreimal pulsieren lassen, dann auf 2.0 fixieren
    private func glowAnimationLoop() {
        if glowCount < 2 {
            withAnimation(.easeInOut(duration: 1.5)) {
                glowIntensity = 2
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    glowIntensity = 0.3
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    glowCount += 1
                    glowAnimationLoop()
                }
            }
        } else {
            // Nach 3 Wiederholungen bleibt Glow auf 2
            withAnimation(.easeInOut(duration: 1.5)) {
                glowIntensity = 2
            }
        }
    }
}

// SwiftUI Preview für Vollbild
struct GlobeView_Previews: PreviewProvider {
    static var previews: some View {
        GlobeView()
            .previewDevice("iPhone 14 Pro")
    }
}
