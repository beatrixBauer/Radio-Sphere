import SwiftUI

struct AnimatedWaveformView: View {
    var body: some View {
        Image(systemName: "waveform")
            .symbolEffect(.variableColor) // Fügt Farbverlauf hinzu (optional)
            .font(.system(size: 50)) // Größe anpassen
    }
}
