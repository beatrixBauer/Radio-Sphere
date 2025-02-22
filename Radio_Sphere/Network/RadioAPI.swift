import Foundation

class RadioAPI {
    private let baseURL = "https://de1.api.radio-browser.info/json/stations"

    func fetchStations(offset: Int, completion: @escaping ([RadioStation]) -> Void) {
        let urlString = "\(baseURL)?limit=50&offset=\(offset)&hidebroken=true"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Fehler: \(error.localizedDescription)")
                return
            }
            guard let data = data else { return }

            do {
                let decodedData = try JSONDecoder().decode([RadioStation].self, from: data)
                
                DispatchQueue.main.async {
                    completion(decodedData)
                }
            } catch {
                print("JSON-Fehler: \(error)")
            }
        }.resume()
    }

    func searchStations(query: String, completion: @escaping ([RadioStation]) -> Void) {
        let urlString = "\(baseURL)/search?name=\(query)&limit=50&hidebroken=true"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Fehler bei der API-Suche: \(error.localizedDescription)")
                return
            }
            guard let data = data else { return }

            do {
                let decodedData = try JSONDecoder().decode([RadioStation].self, from: data)
                
                DispatchQueue.main.async {
                    completion(decodedData)
                }
            } catch {
                print("JSON-Fehler: \(error)")
            }
        }.resume()
    }
}
