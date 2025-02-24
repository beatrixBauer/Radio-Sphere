//
//  RadioAPI.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.02.25.
//
import Foundation

class RadioAPI {
    private let baseURL = "https://de1.api.radio-browser.info/json/stations/search"

    /// Holt die Top-Radiosender mit Song-Metadaten für Deutschland
    func fetchStations(offset: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        print("Anfrage wird vorbereitet...")

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "limit", value: "100"),
            //URLQueryItem(name: "tag", value: "pop"), // Nur Pop-Sender
            //URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "order", value: "clickcount"),
            URLQueryItem(name: "reverse", value: "true"),
            URLQueryItem(name: "countrycode", value: "DE"),
            URLQueryItem(name: "hidebroken", value: "true"),
            URLQueryItem(name: "lastcheckok", value: "1"), // Nur aktive Sender
            URLQueryItem(name: "has_extended_info", value: "true") // Nur Sender mit Song-Metadaten
        ]

        guard let urlString = components?.url?.absoluteString else {
            completion(.failure(DataError.urlNotValid))
            return
        }

        print("Anfrage an URL: \(urlString)")

        performRequest(urlString: urlString, completion: completion)
    }
    
    /// Suche nach Radiosendern
    func searchStations(query: String, completion: @escaping ([RadioStation]) -> Void) {
        let urlString = "\(baseURL)/search?name=\(query)&limit=50"
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
   /* func searchStations(query: String, completion: @escaping ([RadioStation]) -> Void) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/search?name=\(encodedQuery)&limit=100"
        

        performRequest(urlString: urlString) { result in
            switch result {
            case .success(let data):
                do {
                    // JSON-Daten dekodieren
                    let decodedData = try JSONDecoder().decode([RadioStation].self, from: data)

                    // Ergebnis auf dem Hauptthread zurückgeben
                    DispatchQueue.main.async {
                        completion(decodedData)
                    }
                } catch {
                    print("JSON-Fehler: \(error)")
                }

            case .failure(let error):
                print("Fehler bei der API-Suche: \(error.localizedDescription)")
            }
        }
    }*/

    /// Generische Methode für API-Anfragen
    private func performRequest(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(DataError.urlNotValid))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("RadioSphere/0.1 (in development)", forHTTPHeaderField: "User-Agent")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                completion(.failure(DataError.httpResponseNotValid))
                return
            }

            guard let data = data else {
                completion(.failure(DataError.dataNotFound))
                return
            }

            // Filtere alle Sender ohne HTTPS-Streams
            if let filteredData = self.filterHTTPSStations(from: data) {
                completion(.success(filteredData))
            } else {
                completion(.failure(DataError.dataNotFound))
            }
        }.resume()
    }

    /// Filtert alle Sender, die keine `https://`-Streams haben
    private func filterHTTPSStations(from data: Data) -> Data? {
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                let filteredArray = jsonArray.filter { station in
                    if let url = station["url_resolved"] as? String {
                        return url.lowercased().starts(with: "https")
                    }
                    return false
                }
                return try JSONSerialization.data(withJSONObject: filteredArray, options: [])
            }
        } catch {
            print("Fehler beim Filtern der Streams: \(error)")
        }
        return nil
    }
}




