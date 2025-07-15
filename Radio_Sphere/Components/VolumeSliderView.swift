//
//  VolumeSliderView.swift
//  Radio_Sphere
//

import SwiftUI

// MARK: Anzeige Volume-Slider in der PlayerView

struct VolumeSliderView: View {
    @StateObject private var volumeObserver = AudioManager()

    private let range: ClosedRange<Float> = 0...1

    var body: some View {
        HStack {
            Image(systemName: "volume.slash").foregroundStyle(.gray)
            Slider(value: $volumeObserver.volume, in: range, step: 0.05)
                .tint(.midblue)
                .onChange(of: volumeObserver.volume) { _ in
                    volumeObserver.setSystemVolume(to: volumeObserver.volume)
                }
            Image(systemName: "volume").foregroundStyle(.gray)
        }
        .padding()
    }
}

struct VolumeSliderView_Previews: PreviewProvider {
    static var previews: some View {
        VolumeSliderView()
    }
}
