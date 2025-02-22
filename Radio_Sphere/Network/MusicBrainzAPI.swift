import Foundation

class MusicBrainzAPI {
    // Setzt den User-Agent für die Anfrage
    private let userAgent = "Radio_Sphere/0.1 (beatrix.bauer@gmail.com)"

    // Funktion zum Abrufen des Albumcovers für ein Lied
    func getAlbumCover(artistName: String, trackTitle: String, completion: @escaping (URL?) -> Void) {
        // Setze die URL für die MusicBrainz API (Suche nach Aufnahmen)
        let baseUrl = "https://musicbrainz.org/ws/2/recording"
        var components = URLComponents(string: baseUrl)
        components?.queryItems = [
            URLQueryItem(name: "artist", value: artistName),
            URLQueryItem(name: "recording", value: trackTitle),
            URLQueryItem(name: "fmt", value: "json")
        ]
        
        guard let url = components?.url else {
            print("Fehler: URL konnte nicht erstellt werden")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        // Abrufen der Daten von der MusicBrainz API
        URLSession.shared.dataTask(with: request) { data, response, error in
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
            
            // Verarbeiten der Antwort
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let recordings = json["recording-list"] as? [[String: Any]],
                   !recordings.isEmpty {
                    
                    // Holen der Release-IDs aus der Antwort
                    var releaseIds: [String] = []
                    for recording in recordings {
                        if let releases = recording["release-list"] as? [[String: Any]] {
                            for release in releases {
                                if let releaseId = release["id"] as? String {
                                    releaseIds.append(releaseId)
                                }
                            }
                        }
                    }
                    
                    // Duplikate entfernen
                    let uniqueReleaseIds = Set(releaseIds)
                    
                    // Das Albumcover aus dem CoverArt Archive holen
                    self.getCoverFromCoverArtArchive(releaseIds: Array(uniqueReleaseIds), completion: completion)
                    
                } else {
                    print("Fehler: Keine Ergebnisse von MusicBrainz gefunden")
                    completion(nil)
                }
            } catch {
                print("JSON-Fehler: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    // Funktion zum Abrufen des Covers vom CoverArt Archive
    private func getCoverFromCoverArtArchive(releaseIds: [String], completion: @escaping (URL?) -> Void) {
        for releaseId in releaseIds {
            let url = "https://coverartarchive.org/release/\(releaseId)/front"
            if let requestUrl = URL(string: url) {
                // Anfrage an das CoverArt Archive senden
                URLSession.shared.dataTask(with: requestUrl) { data, response, error in
                    if let error = error {
                        print("Fehler beim Abrufen des Covers: \(error.localizedDescription)")
                        continue
                    }
                    
                    guard let response = response as? HTTPURLResponse,
                          response.statusCode == 307,  // Prüft, ob ein Redirect erfolgt
                          let location = response.allHeaderFields["Location"] as? String,
                          let artworkUrl = URL(string: location) else {
                        print("Kein Albumcover gefunden oder Fehler bei der Antwort")
                        continue
                    }
                    
                    // Gebe die URL des Covers zurück
                    completion(artworkUrl)
                    return
                }.resume()
            }
        }
        
        // Wenn kein Cover gefunden wird
        completion(nil)
    }
}
