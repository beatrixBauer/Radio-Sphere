//
//  MusicBrainzAPI.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 22.02.25.
//


import Foundation

class MusicBrainzAPI {
    static let shared = MusicBrainzAPI()
    
    private let userAgent = "Radio_Sphere/0.1 (beatrix.bauer@gmail.com)"
    
    func getAlbumCover(artistName: String, trackTitle: String, completion: @escaping (URL?) -> Void) {
        // URL-Encoding der Suchbegriffe
        guard let encodedArtist = artistName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedTrack = trackTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Fehler beim Encoding der Suchbegriffe")
            completion(nil)
            return
        }
        
        let urlString = "https://musicbrainz.org/ws/2/recording/?query=artist:\(encodedArtist)%20AND%20recording:\(encodedTrack)&fmt=json"
        
        guard let url = URL(string: urlString) else {
            print("Fehler: URL konnte nicht erstellt werden")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        print("Anfrage an MusicBrainz: \(urlString)")
        
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
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let recordings = json["recordings"] as? [[String: Any]], !recordings.isEmpty {
                    
                    var releaseIds: [String] = []
                    
                    for recording in recordings {
                        if let releases = recording["releases"] as? [[String: Any]] {
                            for release in releases {
                                if let releaseId = release["id"] as? String {
                                    releaseIds.append(releaseId)
                                }
                            }
                        }
                    }

                    if let firstReleaseId = releaseIds.first {
                        self.getCoverFromCoverArtArchive(releaseId: firstReleaseId, completion: completion)
                    } else {
                        print("Keine Release-ID gefunden")
                        completion(nil)
                    }
                    
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
    
    private func getCoverFromCoverArtArchive(releaseId: String, completion: @escaping (URL?) -> Void) {
        let url = "https://coverartarchive.org/release/\(releaseId)/front"
        
        guard let requestUrl = URL(string: url) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: requestUrl) { data, response, error in
            if let error = error {
                print("Fehler beim Abrufen des Covers: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("Ungültige Serverantwort")
                completion(nil)
                return
            }
            
            if response.statusCode == 200 {
                print("Cover gefunden: \(requestUrl)")
                completion(requestUrl)
            } else {
                print("Kein Albumcover verfügbar (Status: \(response.statusCode))")
                completion(nil)
            }
        }.resume()
    }
}

