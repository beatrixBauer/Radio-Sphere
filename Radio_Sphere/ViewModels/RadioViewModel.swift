import SwiftUI

class RadioViewModel: ObservableObject {
    @Published var stations: [RadioStation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadStations(offset: Int = 0) {
        isLoading = true
        errorMessage = nil
        
        DataManager.getStations(offset: offset) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let stations):
                    self?.stations = stations
                case .failure(let error):
                    self?.errorMessage = "Fehler: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func searchStations(query: String) {
        isLoading = true
        errorMessage = nil
        
        DataManager.searchStations(query: query) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let stations):
                    self?.stations = stations
                case .failure(let error):
                    self?.errorMessage = "Fehler: \(error.localizedDescription)"
                }
            }
        }
    }
}
