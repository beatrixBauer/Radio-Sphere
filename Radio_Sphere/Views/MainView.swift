import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            StationsView(category: .all)
                .tabItem {
                    Label("Sender", systemImage: "radio.fill")
                }
            
            PlayerView(station: RadioStation.example, 
                       filteredStations: [RadioStation.example], 
                       categoryTitle: "Now Playing")
                .tabItem {
                    Label("Player", systemImage: "play.circle.fill")
                }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
#Preview {
    MainView()
}
