//
//  VolumeSliderView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 22.02.25.
//

import SwiftUI
import MediaPlayer
import AVFoundation

struct VolumeSliderView: View {
    @StateObject private var volumeObserver = VolumeObserver()
    
    private let range: ClosedRange<Float> = 0...1

    var body: some View {
        HStack {
            Image(systemName: "volume.slash").foregroundStyle(.gray)
            Slider(value: $volumeObserver.volume, in: range, step: 0.05)
                .onChange(of: volumeObserver.volume) {
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
