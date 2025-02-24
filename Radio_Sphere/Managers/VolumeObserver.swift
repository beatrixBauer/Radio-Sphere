import SwiftUI
import MediaPlayer
import AVFoundation

class VolumeObserver: NSObject, ObservableObject {
    @Published var volume: Float = AVAudioSession.sharedInstance().outputVolume
    private var audioSession = AVAudioSession.sharedInstance()

    override init() {
        super.init()
        startObserving()
    }

    deinit {
        stopObserving()
    }

    private func startObserving() {
        do {
            try audioSession.setActive(true)
            audioSession.addObserver(self, forKeyPath: "outputVolume", options: [.new], context: nil)
        } catch {
            print("Fehler beim Aktivieren der AVAudioSession: \(error)")
        }
    }

    private func stopObserving() {
        audioSession.removeObserver(self, forKeyPath: "outputVolume")
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "outputVolume" {
            DispatchQueue.main.async {
                self.volume = self.audioSession.outputVolume
            }
        }
    }
}
