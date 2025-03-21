//
//  AnimatedWaveformView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 20.03.25.
//


import SwiftUI

struct AnimatedWaveformView: View {
    var body: some View {
        Image(systemName: "waveform")
            .symbolEffect(.variableColor) // Fügt Farbverlauf hinzu (optional)
            .font(.system(size: 20)) // Größe anpassen
            .foregroundStyle(.white)
    }
}

#Preview {
    AnimatedWaveformView()
        .preferredColorScheme(.dark)
}
