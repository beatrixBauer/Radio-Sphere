//
//  RadioAPI.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 03.04.25.
//

import Foundation

// MARK: Abfrage von Radio-Browser API

class RadioAPI {
    private let session: URLSession
    private var availableBaseURLs: [String] {
        return getRadioBrowserBaseURLs()
    }
    private var baseURL: String {
        return availableBaseURLs.first! + "/json/stations"
    }
    
    private let userAgent = "Radio Sphere/1.0 (iOS; beatrix.bauer@gmail.com)"

    // Initializer mit übergebener URLSession – Standard ist URLSession.shared
    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchAllStations(completion: @escaping ([RadioStation]) -> Void) {
        // baseURL = "<bestes‑Mirror>/json/stations"
        let remoteURL = baseURL + "/search?hidebroken=true&lastcheckok=1&is_https=true&limit=50000"
        print("fetching all stations from \(remoteURL)")
        performRequest(urlString: remoteURL, completion: completion)
    }

    /// Abfrage aller Stationen im Mobilfunknetzt mit limit und Pagination
    func fetchStations(offset: Int, limit: Int, completion: @escaping ([RadioStation]) -> Void) {
        let remoteURL = baseURL + "/search?hidebroken=true&lastcheckok=1&is_https=true&offset=\(offset)&limit=\(limit)"
        performRequest(urlString: remoteURL, completion: completion)
    }

    private func performRequest(urlString: String, completion: @escaping ([RadioStation]) -> Void) {
        attemptRequest(urlString: urlString, remainingBaseURLs: availableBaseURLs, completion: completion)
    }

    private func attemptRequest(urlString: String, remainingBaseURLs: [String], completion: @escaping ([RadioStation]) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Fehler: Ungültige URL")
            completion([])
            return
        }
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        session.dataTask(with: request) { data, response, error in
            // Bei einem Fehler wird ein alternativer Server versucht
            if let error = error {
                print("Fehler bei der API-Anfrage: \(error.localizedDescription)")
                if let currentHost = URL(string: urlString)?.host,
                   let alternative = remainingBaseURLs.first(where: { URL(string: $0)?.host != currentHost }) {
                    if let newURL = URL(string: urlString) {
                        let newHost = URL(string: alternative)?.host ?? ""
                        var components = URLComponents(url: newURL, resolvingAgainstBaseURL: false)
                        components?.host = newHost
                        if let newURLString = components?.url?.absoluteString {
                            print("Versuche alternativen Server: \(newURLString)")
                            let updatedRemaining = remainingBaseURLs.filter { $0 != alternative }
                            self.attemptRequest(urlString: newURLString, remainingBaseURLs: updatedRemaining, completion: completion)
                            return
                        }
                    }
                }
                completion([])
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Server-Antwort: Status Code \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("Fehler: Keine Daten erhalten")
                completion([])
                return
            }

            do {
                let decodedData = try JSONDecoder().decode([RadioStation].self, from: data)
                DispatchQueue.main.async {
                    completion(decodedData)
                }
            } catch {
                print("JSON-Fehler: \(error)")
                completion([])
            }
        }.resume()
    }

    // Ermittlung der verfügbaren Server von Radio-Browser (DE soll bevorzugt werden)
    func getRadioBrowserBaseURLs() -> [String] {
        let fallbackURLs = [
            "https://de1.api.radio-browser.info",
            "https://de2.api.radio-browser.info",
            "https://fi1.api.radio-browser.info/"
        ]
        let hostname: CFString = "all.api.radio-browser.info" as CFString
        var streamError = CFStreamError()
        guard let hostRef = CFHostCreateWithName(nil, hostname).takeRetainedValue() as CFHost? else {
            return fallbackURLs
        }
        let resolutionSuccess = CFHostStartInfoResolution(hostRef, .addresses, &streamError)
        if !resolutionSuccess {
            print("Fehler beim Auflösen von \(hostname): \(streamError)")
            return fallbackURLs
        }
        var resolved: DarwinBoolean = false
        guard let addressesCF = CFHostGetAddressing(hostRef, &resolved)?.takeUnretainedValue() as? [Data] else {
            return fallbackURLs
        }
        var hostnames = Set<String>()
        for addressData in addressesCF {
            addressData.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
                guard let addrPtr = pointer.baseAddress?.assumingMemoryBound(to: sockaddr.self) else { return }
                var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(addrPtr, socklen_t(addressData.count), &hostBuffer, socklen_t(hostBuffer.count), nil, 0, NI_NAMEREQD) == 0 {
                    let hostName = String(cString: hostBuffer)
                    hostnames.insert(hostName)
                }
            }
        }
        let sorted = hostnames.sorted { lhs, rhs in
            let lhsIsDE = lhs.hasPrefix("de")
            let rhsIsDE = rhs.hasPrefix("de")
            if lhsIsDE && !rhsIsDE {
                return true
            } else if !lhsIsDE && rhsIsDE {
                return false
            } else {
                return lhs < rhs
            }
        }
        let urls = sorted.map { "https://" + $0 }
        return urls.isEmpty ? fallbackURLs : urls
    }
}
