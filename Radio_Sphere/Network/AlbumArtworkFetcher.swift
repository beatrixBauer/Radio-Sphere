import Foundation

class AlbumArtworkFetcher {
    func fetchAlbumArtwork(artist: String, track: String, completion: @escaping (URL?) -> Void) {
        let baseURL = "https://itunes.apple.com/search"
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "term", value: "\(artist) \(track)"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: "1")
        ]

        guard let url = components?.url else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]], !results.isEmpty,
                   let artworkUrlString = results[0]["artworkUrl600"] as? String {
                    completion(URL(string: artworkUrlString))
                    return
                }
            } catch {
                print("Fehler beim Abrufen des Albumcovers: \(error)")
            }

            completion(nil)
        }.resume()
    }
}
