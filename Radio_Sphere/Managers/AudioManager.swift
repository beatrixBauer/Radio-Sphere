//
//  AudioManager.swift
//  Radio_Sphere
//

import SwiftUI
import MediaPlayer
import AVFoundation
import Combine

// MARK: AudioManager ist eine Singleton-Klasse, die die Audio-Session verwaltet, die Systemlautstärke beobachtet und steuert.
// wird von der Komponente Volumeslider verwendet

class AudioManager: NSObject, ObservableObject {
    // Singleton-Instanz für globalen Zugriff
    static let shared = AudioManager()

    // Beobachtung der Lautstärke
    @Published var volume: Float = AVAudioSession.sharedInstance().outputVolume

    // Referenz auf die Audiosession
    private var audioSession = AVAudioSession.sharedInstance()

    // zur Änderung der Systemlautstärke
    private var volumeView = MPVolumeView()

    // Cancellable für die Beobachtung der Lautstärke-Änderungen via Combine.
    private var cancellable: AnyCancellable?

    // Variable zeigt an dass die Lautstärkeänderungen vom Slider kommen
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

    // MPVolumeView ist ein von Apple bereitgestelltes UI-Element, das einen systemeigenen Lautstärkeregler enthält.
    // Da iOS die direkte Änderung der Systemlautstärke nicht erlaubt, wird die MPVolumeView im Hintergrund genutzt,
    // um die Systemlautstärke über ihren internen Slider zu steuern.
    // Um jedoch die eigene, designangepasste Lautstärkeregelung (VolumeSliderView) anzuzeigen,
    // wird die MPVolumeView "versteckt" – also außerhalb des sichtbaren Bereichs positioniert.

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

    // Aktivierung der AudioSession
    private func activateAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("AVAudioSession aktiviert")
        } catch {
            print("Fehler beim Aktivieren der AVAudioSession: \(error)")
        }
    }

    // Beobachtung starten
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

    // Systemlautstärke ändern
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
