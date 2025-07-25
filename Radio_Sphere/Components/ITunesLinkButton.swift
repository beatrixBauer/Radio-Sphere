//
//  ITunesLinkButton.swift
//  Radio_Sphere
//


import SwiftUI

// MARK: Anforderung von Apple bei Nutzung der iTunesAPI für das Albumcover
// es muss eine Verlinkung zum Musicstore vorhanden sein

struct ITunesLinkButton: View {
    let trackUrl: URL?
    var fontSize: CGFloat = 13
    
    var body: some View {
        if let trackUrl = trackUrl {
            Button(action: {
                UIApplication.shared.open(trackUrl, options: [:], completionHandler: nil)
            }) {
                HStack {
                    Image(systemName: "apple.logo")
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                    Text("Jetzt bei iTunes")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                        .padding(.trailing, 10)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8),
                            Color.darkblue.opacity(0.9),
                            Color.darkred.opacity(0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    ITunesLinkButton(trackUrl: URL(string: "https://itunes.apple.com/de/album/id1477471331")!)
}
