//
//  MusicBrainzAPI.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 22.04.25.
//

import Foundation

// Codable-Modelle für die MusicBrainz-Antwort
struct MusicBrainzResponse: Codable {
    let recordings: [Recording]
}

struct Recording: Codable {
    let releases: [Release]?
}

struct Release: Codable {
    let id: String
}

enum MusicBrainzError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case noRecordingsFound
    case noReleaseIDFound
    case networkError(Error)
}

class MusicBrainzAPI {
    static let shared = MusicBrainzAPI()

    private let userAgent = "Radio_Sphere/1.0 (beatrix.bauer@gmail.com)"

    // MARK: Fragt das Album-Cover bei MusicBrainz ab, falls verfügbar
    func getAlbumCover(artistName: String, trackTitle: String, completion: @escaping (Result<URL, MusicBrainzError>) -> Void) {

        // URLComponents für eine sichere URL-Erstellung
        var components = URLComponents(string: "https://musicbrainz.org/ws/2/recording/")!
        let queryItems = [
            URLQueryItem(name: "query", value: "artist:\(artistName) AND recording:\(trackTitle)"),
            URLQueryItem(name: "fmt", value: "json")
        ]
        components.queryItems = queryItems

        guard let url = components.url else {
            print("Fehler: URL konnte nicht erstellt werden")
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        print("Anfrage an MusicBrainz: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, _, error in
            // Fehler beim Netzwerkabruf
            if let error = error {
                print("Netzwerkfehler: \(error.localizedDescription)")
                completion(.failure(.networkError(error)))
                return
            }

            guard let data = data else {
                print("Fehler: Keine Daten erhalten")
                completion(.failure(.noData))
                return
            }

            do {
                let decoder = JSONDecoder()
                let mbResponse = try decoder.decode(MusicBrainzResponse.self, from: data)

                guard !mbResponse.recordings.isEmpty else {
                    print("Fehler: Keine Aufnahmen gefunden")
                    completion(.failure(.noRecordingsFound))
                    return
                }

                var releaseIds: [String] = []
                for recording in mbResponse.recordings {
                    if let releases = recording.releases {
                        for release in releases {
                            releaseIds.append(release.id)
                        }
                    }
                }

                guard let firstReleaseId = releaseIds.first else {
                    print("Keine Release-ID gefunden")
                    completion(.failure(.noReleaseIDFound))
                    return
                }

                // Wenn eine Release-ID gefunden wurde, wird das Cover abgerufen
                self.getCoverFromCoverArtArchive(releaseId: firstReleaseId, completion: completion)

            } catch {
                print("Decoding-Fehler: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }

    // MARK: Funktion für die Anfrage bei CoverArtArchive
    private func getCoverFromCoverArtArchive(releaseId: String, completion: @escaping (Result<URL, MusicBrainzError>) -> Void) {
        let urlString = "https://coverartarchive.org/release/\(releaseId)/front"

        guard let requestUrl = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: requestUrl) { _, response, error in
            if let error = error {
                print("Fehler beim Abrufen des Covers: \(error.localizedDescription)")
                completion(.failure(.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Ungültige Serverantwort")
                completion(.failure(.noData))
                return
            }

            if httpResponse.statusCode == 200 {
                print("Cover gefunden: \(requestUrl)")
                completion(.success(requestUrl))
            } else {
                print("Kein Albumcover verfügbar (Status: \(httpResponse.statusCode))")
                completion(.failure(.noData))
            }
        }.resume()
    }
}
