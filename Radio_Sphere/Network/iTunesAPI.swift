//
//  iTunesAPI.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 22.04.25.
//

import Foundation

class iTunesAPI {
    static let shared = iTunesAPI()

    // MARK: Fragt das Album-Cover eines Songs von iTunes ab

    func getAlbumCover(artist: String, track: String, completion: @escaping (URL?, URL?) -> Void) {
        let query = "\(artist) \(track)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let regionCode = Locale.current.region?.identifier ?? "DE"
        let urlString = "https://itunes.apple.com/search?term=\(query)&entity=song&limit=1&country=\(regionCode)" // Link zum iTunesstore

        guard let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil {
                completion(nil, nil)
                return
            }

            guard let data = data else {
                completion(nil, nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let artworkUrl = firstResult["artworkUrl100"] as? String,
                   let trackUrlString = firstResult["trackViewUrl"] as? String {

                    let highResArtworkUrlString = artworkUrl
                        .replacingOccurrences(of: "100x100", with: "1200x1200")
                        .replacingOccurrences(of: "600x600", with: "1200x1200")
                    let highResArtworkUrl = URL(string: highResArtworkUrlString)
                    let trackUrl = URL(string: trackUrlString)

                    completion(highResArtworkUrl, trackUrl)
                } else {
                    completion(nil, nil)
                }
            } catch {
                completion(nil, nil)
            }
        }.resume()
    }

}
