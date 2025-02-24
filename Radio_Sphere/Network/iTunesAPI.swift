//
//  iTunesAPI.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 22.02.25.
//


import Foundation

class iTunesAPI {
    static let shared = iTunesAPI()
    
    func getAlbumCover(artist: String, track: String, completion: @escaping (URL?) -> Void) {
        let query = "\(artist) \(track)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://itunes.apple.com/search?term=\(query)&entity=song&limit=1"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let artworkUrl = results.first?["artworkUrl100"] as? String {
                    
                    let highResArtworkUrl = artworkUrl
                        .replacingOccurrences(of: "100x100", with: "1200x1200")
                        .replacingOccurrences(of: "600x600", with: "1200x1200")

                    completion(URL(string: highResArtworkUrl))
                    
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
