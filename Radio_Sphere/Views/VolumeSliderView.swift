import SwiftUI
import MediaPlayer

struct VolumeSliderView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let volumeView = MPVolumeView()
        volumeView.showsRouteButton = false // Falls AirPlay nicht angezeigt werden soll
        volumeView.showsVolumeSlider = true
        return volumeView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}