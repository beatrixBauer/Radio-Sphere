//
//  RadioStation.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.02.25.
//

import SwiftUI

struct RadioStation: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let url: String
    let country: String
    let language: String
    let tags: String?
    let lastcheckok: Int
    let imageURL: String?
    let codec: String?

    enum CodingKeys: String, CodingKey {
        case id = "stationuuid"
        case name
        case url = "url_resolved"
        case country
        case language
        case tags
        case lastcheckok
        case imageURL = "favicon"
        case codec
    }

    static func == (lhs: RadioStation, rhs: RadioStation) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.url == rhs.url &&
               lhs.country == rhs.country &&
               lhs.tags == rhs.tags &&
               lhs.imageURL == rhs.imageURL
    }

    // Prüft, ob der Sender ICY-Metadaten oder ID3 nutzt
    func isICYStream() -> Bool {
        if let codec = self.codec {
            return ["MP3", "AAC", "OGG", "OPUS", "FLAC"].contains(codec.uppercased())
        }
        return false
    }

    // Standardwerte für optionale Felder
    init(
        id: String = UUID().uuidString,
        name: String = "Unbekannte Station",
        url: String = "",
        country: String = "Unbekannt",
        language: String = "Unbekannt",
        tags: String? = nil,
        lastcheckok: Int = 0,
        imageURL: String? = nil,
        codec: String? = nil
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.country = country
        self.language = language
        self.tags = tags
        self.lastcheckok = lastcheckok
        self.imageURL = imageURL
        self.codec = codec
    }
}

// MARK: - SwiftUI-kompatible Bilddarstellung
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
