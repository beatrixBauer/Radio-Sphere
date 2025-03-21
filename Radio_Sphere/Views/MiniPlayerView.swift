import SwiftUI

struct MiniPlayerView: View {
    @ObservedObject var manager = StationsManager.shared
    @State private var isNavigatingToPlayer = false
    
    var body: some View {
        if let station = manager.currentStation, manager.isPlaying {
            NavigationLink(destination: PlayerView(station: station, 
                                                   filteredStations: manager.filteredStations, 
                                                   categoryTitle: "Jetzt läuft"), 
                           isActive: $isNavigatingToPlayer) {
                EmptyView()
            }
            
            VStack {
                HStack {
                    // Albumcover oder Senderlogo
                    if let artworkURL = manager.currentArtworkURL {
                        AsyncImage(url: artworkURL) { image in
                            image.resizable()
                        } placeholder: {
                            Image(systemName: "music.note")
                                .resizable()
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    VStack(alignment: .leading) {
                        Text(manager.currentTrack.isEmpty ? "Live-Übertragung" : manager.currentTrack)
                            .font(.headline)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Text(manager.currentArtist.isEmpty ? station.decodedName : manager.currentArtist)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .onTapGesture {
                    isNavigatingToPlayer = true
                }
            }
            .transition(.move(edge: .bottom))
        }
    }
}
