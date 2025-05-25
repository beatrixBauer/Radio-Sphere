//
//  RadioStation.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 01.04.25.
//

import SwiftUI
import Foundation

struct RadioStation: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let url: String
    let country: String
    let countrycode: String
    let state: String?
    let language: String
    let tags: String?
    let lastcheckok: Int
    let imageURL: String?
    let codec: String?
    let clickcount: Int
    var hasExtendedInfo: Bool = false
    let geo_lat: Double?
    let geo_long: Double?

    enum CodingKeys: String, CodingKey {
        case id = "stationuuid"
        case name
        case url = "url_resolved"
        case country
        case countrycode
        case state
        case language
        case tags
        case lastcheckok
        case imageURL = "favicon"
        case codec
        case clickcount
        case hasExtendedInfo = "has_extended_info"
        case geo_lat
        case geo_long
    }

    // Standardwerte für optionale Felder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        country = try container.decode(String.self, forKey: .country)
        countrycode = try container.decode(String.self, forKey: .countrycode)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        language = try container.decode(String.self, forKey: .language)
        tags = try? container.decode(String?.self, forKey: .tags)
        lastcheckok = try container.decode(Int.self, forKey: .lastcheckok)
        imageURL = try? container.decode(String?.self, forKey: .imageURL)
        codec = try? container.decode(String?.self, forKey: .codec)
        clickcount = try container.decode(Int.self, forKey: .clickcount)
        hasExtendedInfo = try container.decodeIfPresent(Bool.self, forKey: .hasExtendedInfo) ?? false

        // Sicheres Dekodieren von geo_lat und geo_long
        if let latString = try? container.decode(String.self, forKey: .geo_lat),
           let lat = Double(latString) {
            geo_lat = lat
        } else if let latNumber = try? container.decode(Double.self, forKey: .geo_lat) {
            geo_lat = latNumber
        } else {
            geo_lat = nil
        }

        if let lonString = try? container.decode(String.self, forKey: .geo_long),
           let lon = Double(lonString) {
            geo_long = lon
        } else if let lonNumber = try? container.decode(Double.self, forKey: .geo_long) {
            geo_long = lonNumber
        } else {
            geo_long = nil
        }
    }

    static func == (lhs: RadioStation, rhs: RadioStation) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.url == rhs.url &&
               lhs.country == rhs.country &&
               lhs.tags == rhs.tags &&
               lhs.imageURL == rhs.imageURL
    }

    // Prüft, ob der Sender ICY-Metadaten oder ID3 nutzt (wurde zum Testen verwendet)
    func isICYStream() -> Bool {
        if let codec = self.codec {
            return ["MP3", "AAC", "OGG", "OPUS", "FLAC"].contains(codec.uppercased())
        }
        return false
    }

    // MARK: - Dekodierte Eigenschaften zur Korrektur von Sonderzeichen

    var decodedName: String {
        return name.fixEncoding()
    }

    var decodedTags: String? {
        return tags?.fixEncoding()
    }

    var decodedCountry: String {
        return country.fixEncoding()
    }

    var decodedLanguage: String {
        return language.fixEncoding()
    }

}

// MARK: - Lädt das Logo der jeweiligen Radiostation oder des Platzhalters
struct StationImageView: View {
    let imageURL: String?

    var body: some View {
        AsyncImage(url: URL(string: imageURL ?? "")) { phase in
            if let image = phase.image {
                image.resizable().scaledToFit()
            } else {
                Image("stationPlaceholder").resizable().scaledToFit()
            }
        }
        .frame(width: 100, height: 100)
        .cornerRadius(10)
    }
}

extension RadioStation {
    private static let excludedStations: Set<String> = [
        "OS-Radio"
    ]
    
    /// Host + Path, bei Rautemusik ohne stream-Nummer
    var duplicateKey: String? {
        guard let c = URLComponents(string: url), let host = c.host else { return nil }
        let cleanHost = host.replacingOccurrences(of: #"\.stream\d+\."#,
                                                  with: ".stream.",
                                                  options: .regularExpression)
        return (cleanHost + c.path).lowercased()    // z. B. rautemusik.stream.radiohost.de/breakz
    }
}

