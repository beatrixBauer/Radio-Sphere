//
//  StationsManagerPerformanceTests.swift
//  Radio Sphere
//
// Test der Streamlatenzen zum Laden von Song-Metadaten

import XCTest
@testable import Radio_Sphere  // oder euer Modulname

final class StationsManagerPerformanceTests: XCTestCase {
    private var manager: StationsManager!

    override func setUp() {
        super.setUp()
        // Singleton aus Tests zurücksetzen, falls nötig
        manager = StationsManager.shared
    }

    /// Lädt die Test-Stations aus testStations.json und decodiert sie mithilfe
    /// des gleichen JSON-Decoders und Models wie im Produktionscode :contentReference[oaicite:0]{index=0}
    private func loadTestStations() throws -> [RadioStation] {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "testStations", withExtension: "json") else {
            XCTFail("testStations.json fehlt im Test-Bundle")
            return []
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([RadioStation].self, from: data)
    }

    func testStreamMetadataAndArtworkLatency() throws {
        let stations = try loadTestStations()
        // Arrays zum Sammeln der Werte
        var streamLatencies: [TimeInterval] = []
        var metadataLatencies: [TimeInterval] = []
        var artworkLatencies: [TimeInterval] = []

        for station in stations {
            // Drei Expectations, eine pro Latenzmessung
            let streamExp   = expectation(description: "Stream-Start für \(station.name)")
            let metadataExp = expectation(description: "Metadaten für \(station.name)")
            let artworkExp  = expectation(description: "Artwork für \(station.name)")

            // Auf die neuen Hooks subscriben
            manager.onStreamLatencyMeasured = { latency in
                streamLatencies.append(latency)
                streamExp.fulfill()
            }
            manager.onMetadataLatencyMeasured = { latency in
                metadataLatencies.append(latency)
                metadataExp.fulfill()
            }
            manager.onArtworkLatencyMeasured = { latency in
                artworkLatencies.append(latency)
                artworkExp.fulfill()
            }

            // Sender starten – hier wird in set(station:) playStartTime gesetzt :contentReference[oaicite:1]{index=1}
            manager.set(station: station)

            // Auf alle drei Events warten
            wait(for: [streamExp, metadataExp, artworkExp], timeout: 15.0)
        }
        
        // Durchschnitt berechnen
        let avgStream   = streamLatencies.reduce(0, +) / Double(streamLatencies.count)
        let avgMetadata = metadataLatencies.reduce(0, +) / Double(metadataLatencies.count)
        let avgArtwork  = artworkLatencies.reduce(0, +) / Double(artworkLatencies.count)

        // Am Ende prüfen, dass wir für jeden Sender genau einen Wert haben
        XCTAssertEqual(streamLatencies.count,   stations.count, "Jeder Sender sollte eine Stream-Latenz liefern")
        XCTAssertEqual(metadataLatencies.count, stations.count, "Jeder Sender sollte eine Metadaten-Latenz liefern")
        XCTAssertEqual(artworkLatencies.count,  stations.count, "Jeder Sender sollte eine Artwork-Latenz liefern")

        // Optional: Performance-Auswertung oder Logging
        print("--------------------------------------------------------------------------------")
        print("Zusammenfassung Latenzwerte: \n")
        print("Stream-Latenzen:   \(streamLatencies)")
        print("Metadata-Latenzen: \(metadataLatencies)")
        print("Artwork-Latenzen:  \(artworkLatencies)\n")

        print("Durchschnittliche Latenzwerte: \n")
        print("Stream-Latenz-Avg: \(avgStream) s")
        print("Metadata-Latenz-Avg: \(avgMetadata) s")
        print("Artwork-Latenz-Avg: \(avgArtwork) s")
        print("--------------------------------------------------------------------------------")
 
    }
}
