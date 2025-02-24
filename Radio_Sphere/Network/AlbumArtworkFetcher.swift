//
//  AlbumArtworkFetcher.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.02.25.
//


import Foundation

class AlbumArtworkFetcher {
    func fetchAlbumArtwork(artist: String, track: String, completion: @escaping (URL?) -> Void) {
        let baseURL = "https://itunes.apple.com/search"
        
        // URL-codierte Suchbegriffe
        let searchTerm = "\(artist) \(track)"
        guard let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Fehler: Suchbegriff konnte nicht kodiert werden.")
            completion(nil)
            return
        }

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "term", value: encodedSearchTerm),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: "1")
        ]

        guard let url = components?.url else {
            print("Fehler: URL konnte nicht erstellt werden")
            completion(nil)
            return
        }

        print("iTunes API Request: \(url)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Fehler bei API-Request: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("Fehler: Keine Daten erhalten")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]], !results.isEmpty,
                   let artworkUrlString = results[0]["artworkUrl600"] as? String {
                    print("iTunes Albumcover gefunden: \(artworkUrlString)")
                    completion(URL(string: artworkUrlString))
                    return
                } else {
                    print("Kein Albumcover in iTunes API gefunden")
                }
            } catch {
                print("JSON-Fehler: \(error)")
            }

            completion(nil)
        }.resume()
    }
}



