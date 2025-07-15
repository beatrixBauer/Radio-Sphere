//
//  iTunesAPI.swift
//  Radio_Sphere
//


import Foundation

class iTunesAPI {
    static let shared = iTunesAPI()

    // MARK: Prüft per HEAD-Request, ob eine Ressource existiert
    private func urlExists(_ url: URL, completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }
    
    // MARK: Fragt das Album-Cover eines Songs von iTunes ab

    func getAlbumCover(artist: String, track: String, completion: @escaping (URL?, URL?) -> Void) {
           let query = "\(artist) \(track)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
           let regionCode = Locale.current.region?.identifier ?? "US"
           let urlString =
             "https://itunes.apple.com/search?term=\(query)" +
             "&entity=song&limit=1&country=\(regionCode)"

           guard let url = URL(string: urlString) else {
               completion(nil, nil)
               return
           }

           URLSession.shared.dataTask(with: url) { data, _, error in
               guard error == nil, let data = data else {
                   completion(nil, nil)
                   return
               }

               do {
                   if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let results = json["results"] as? [[String: Any]],
                      let firstResult = results.first,
                      let artworkUrl = firstResult["artworkUrl100"] as? String,
                      let trackUrlString = firstResult["trackViewUrl"] as? String {

                       let trackUrl = URL(string: trackUrlString)
                       // URLs für 1200x1200 und 600x600 auf Basis von artworkUrl100
                       let highResStr = artworkUrl.replacingOccurrences(of: "100x100", with: "1200x1200")
                       let medResStr  = artworkUrl.replacingOccurrences(of: "100x100", with: "600x600")
                       guard let highResURL = URL(string: highResStr) else {
                           DispatchQueue.main.async { completion(nil, trackUrl) }
                           return
                       }
                       // 1. Teste 1200x1200
                       self.urlExists(highResURL) { existsHigh in
                           if existsHigh {
                               DispatchQueue.main.async { completion(highResURL, trackUrl) }
                           } else {
                               // 2. Teste 600x600
                               if let medResURL = URL(string: medResStr) {
                                   self.urlExists(medResURL) { existsMed in
                                       DispatchQueue.main.async {
                                           completion(existsMed ? medResURL : nil, trackUrl)
                                       }
                                   }
                               } else {
                                   DispatchQueue.main.async { completion(nil, trackUrl) }
                               }
                           }
                       }
                   } else {
                       DispatchQueue.main.async { completion(nil, nil) }
                   }
               } catch {
                   DispatchQueue.main.async { completion(nil, nil) }
               }
           }.resume()
       }
    
    /*func getAlbumCover(artist: String, track: String, completion: @escaping (URL?, URL?) -> Void) {
        let query = "\(artist) \(track)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let regionCode = Locale.current.region?.identifier ?? "US"
        let urlString =
          "https://itunes.apple.com/search?term=\(query)" +
          "&entity=song&limit=1&country=\(regionCode)"

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
    }*/

}
