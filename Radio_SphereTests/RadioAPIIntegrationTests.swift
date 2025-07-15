//
//  RadioAPIIntegrationTests.swift
//  Radio Sphere
//
// Test der Radio-API -> muss internationale Streams liefern

import XCTest

final class RadioAPIIntegrationTests: XCTestCase {

    func testFetchRemoteStations_ReturnsMultipleCountries() {
        let exp = expectation(description: "Live API call")
        let url = URL(string:
          "https://de1.api.radio-browser.info/json/stations/search?hidebroken=true&lastcheckok=1&is_https=true&limit=50000"
        )!

        URLSession.shared.dataTask(with: url) { data, resp, err in
            // 1) Netzwerkfehler abfangen
            if let err = err {
                XCTFail("Netzwerkfehler: \(err)")
                exp.fulfill()
                return
            }

            // 2) HTTP-Status prüfen
            guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
                let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
                XCTFail("Unerwarteter HTTP-Status: \(code)")
                exp.fulfill()
                return
            }

            // 3) Daten prüfen
            guard let data = data else {
                XCTFail("Keine Daten erhalten")
                exp.fulfill()
                return
            }

            do {
                // 4) JSON in dein RadioStation-Modell decodieren
                let stations = try JSONDecoder().decode([RadioStation].self, from: data)

                // 5) Es sollten Stationen zurückkommen
                XCTAssertFalse(stations.isEmpty, "Erwartet mindestens eine Station")

                // 6) Gruppieren nach countrycode
                let countsByCountry = Dictionary(grouping: stations, by: \.countrycode)
                    .mapValues { $0.count }

                // 7a) Mehr als ein Country-Code insgesamt
                XCTAssertGreaterThan(countsByCountry.keys.count, 1,
                                     "Erwartet Stationen aus mehr als einem Land")

                // 7b) Mindestens ein Country-Code != "DE" (international)
                let hasInternational = countsByCountry.keys.contains { $0 != "DE" }
                XCTAssertTrue(hasInternational,
                              "Es müssen internationale Sender geladen werden (Country-Code != DE)")

                // 8) Konsole-Ausgabe für deinen Nachweis in der Arbeit
                print("Anzahl eindeutiger Country-Codes:", countsByCountry.keys.count, terminator: "\n")
                //print("Country-Codes aus Live-API:", countsByCountry.keys.sorted())

            } catch {
                XCTFail("Decoding-Error: \(error)")
            }

            exp.fulfill()
        }.resume()

        waitForExpectations(timeout: 15.0)
    }
}

