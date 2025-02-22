//
//  ContentView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.02.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RadioViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.stations) { station in
                NavigationLink(destination: StationDetailView(station: station)) {
                    HStack {
                        StationImageView(imageURL: station.imageURL)
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)

                        VStack(alignment: .leading) {
                            Text(station.name)
                                .font(.headline)
                            Text(station.country)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Radio Stations")
            .searchable(text: $viewModel.searchQuery, prompt: "Sender suchen...")
            .onChange(of: viewModel.searchQuery) { newValue in
                if newValue.isEmpty {
                    viewModel.loadStations()
                } else {
                    viewModel.searchStations(query: newValue)
                }
            }
            .onAppear {
                viewModel.loadStations()
            }
        }
    }
}



#Preview {
    ContentView()
}
