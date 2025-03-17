//
//  AudioManager.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 23.02.25.
//

import SwiftUI
import MediaPlayer
import AVFoundation
import Combine

class AudioManager: NSObject, ObservableObject {
    @Published var volume: Float = AVAudioSession.sharedInstance().outputVolume
    private var audioSession = AVAudioSession.sharedInstance()
    private var volumeView = MPVolumeView()
    private var cancellable: AnyCancellable?
    private var isUpdatingFromSlider = false

    override init() {
        super.init()
        activateAudioSession()
        setupHiddenVolumeView()
        startObserving()
    }

    deinit {
        cancellable?.cancel()
    }

    private func setupHiddenVolumeView() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first {
                
                self.volumeView = MPVolumeView(frame: CGRect(x: -2000, y: -2000, width: 1, height: 1))
                self.volumeView.isHidden = false
                keyWindow.addSubview(self.volumeView)

                print("MPVolumeView erfolgreich hinzugefügt")
            } else {
                print("Kein aktives Fenster gefunden")
            }
        }
    }

    private func activateAudioSession() {
        do {
            try audioSession.setCategory(.ambient, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("AVAudioSession aktiviert")
        } catch {
            print("Fehler beim Aktivieren der AVAudioSession: \(error)")
        }
    }

    private func startObserving() {
        activateAudioSession()

        cancellable = audioSession.publisher(for: \.outputVolume)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newVolume in
                guard let self = self else { return }

                if !self.isUpdatingFromSlider {
                    self.volume = newVolume
                    print("Systemlautstärke geändert: \(newVolume)")
                }

                self.isUpdatingFromSlider = false
            }
    }

    func setSystemVolume(to value: Float) {
        isUpdatingFromSlider = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let slider = self.volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider else {
                print("Fehler: MPVolumeView Slider konnte nicht gefunden werden")
                return
            }
            slider.value = value
            print("Lautstärke erfolgreich auf \(value) gesetzt")
        }
    }
}




