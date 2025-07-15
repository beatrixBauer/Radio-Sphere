//
//  RadioCategory.swift
//  Radio_Sphere
//

import SwiftUICore

// MARK: Radiokategorien

enum RadioCategory: String, CaseIterable {

    case local = "Lokale Sender"
    case recent = "Zuletzt gehört"
    case favorites = "Deine Favoriten"
    case news = "Nachrichten"

    case pop = "Pop"
    case schlager = "Schlager"
    case hiphop = "Hip-Hop"
    case rock = "Rock"
    case electronic = "Elektronische Musik"
    case dance = "Dance"
    case chillout = "Chillout"
    case oldies = "Oldies"
    case country = "Country"
    case jazz = "Jazz"
    case classical = "Klassik"
    case tradtionalMusic = "Traditionelle Musik"
    case alternative = "Alternative"
    case latin = "Latin"
    case afrobeat = "Afrobeat"
    case metal = "Metal"
    case punk = "Punk"
    case party = "Party"
    case meditation = "Meditation"
    case artistRadio = "Künstler-Radio"

    // Anzeigenamen für die Kategorien (NavigationTitle StationsView)
    var displayName: String {
        switch self {
        case .pop: return NSLocalizedString("category_pop", comment: "Pop-Sender")
        case .rock: return NSLocalizedString("category_rock", comment: "Rock-Sender")
        case .jazz: return NSLocalizedString("category_jazz", comment: "Jazz-Sender")
        case .classical: return NSLocalizedString("category_classical", comment: "Klassik-Sender")
        case .dance: return NSLocalizedString("category_dance", comment: "Dance-Sender")
        case .electronic: return NSLocalizedString("category_electronic", comment: "Elektronische Musik")
        case .local: return NSLocalizedString("category_local", comment: "Lokale Sender")
        case .recent: return NSLocalizedString("category_recent", comment: "Zuletzt gehört")
        case .favorites: return NSLocalizedString("category_favorites", comment: "Deine Favoriten")
        case .news: return NSLocalizedString("category_news", comment: "Nachrichten-Sender")
        case .country: return NSLocalizedString("category_country", comment: "Country-Sender")
        case .hiphop: return NSLocalizedString("category_hiphop", comment: "Hip-Hop-Sender")
        case .alternative: return NSLocalizedString("category_alternative", comment: "Alternative-Sender")
        case .oldies: return NSLocalizedString("category_oldies", comment: "Oldies")
        case .latin: return NSLocalizedString("category_latin", comment: "Latin")
        case .metal: return NSLocalizedString("category_metal", comment: "Metal")
        case .punk: return NSLocalizedString("category_punk", comment: "Punk")
        case .tradtionalMusic: return NSLocalizedString("category_traditional", comment: "Volksmusik")
        case .chillout: return NSLocalizedString("category_chillout", comment: "Chillout")
        case .meditation: return NSLocalizedString("category_meditation", comment: "Meditation")
        case .party: return NSLocalizedString("category_party", comment: "Party")
        case .schlager: return NSLocalizedString("category_schlager", comment: "Schlager")
        case .afrobeat: return NSLocalizedString("category_afrobeat", comment: "Afrobeat")
        case .artistRadio: return NSLocalizedString("category_artist_radio", comment: "Künstler-Radio")
        }
    }

    // MARK: Haupt- und Fallback-Tags für die API-Abfrage
    var tags: [String] {
        switch self {
        case .pop:
            return ["pop"]
        case .rock:
            return ["rock"]
        case .jazz:
            return ["jazz"]
        case .classical:
            return ["klassik", "classical"]
        case .dance:
            return ["dance", "edm"]
        case .electronic:
            return ["electronic", "dubstep", "house", "techno", "goa"]
        case .country:
            return ["country"]
        case .hiphop:
            return ["hiphop", "hip hop", "hip-hop", "rap", "trap"]
        case .alternative:
            return ["alternative", "indie", "indie rock", "indie pop"]
        case .oldies:
            return ["oldies", "goldies", "retro", "50s", "60s", "70s", "80s", "90s"]
        case .latin:
            return ["salsa", "latino", "tropical", "bachata"]
        case .metal:
            return ["metal"]
        case .punk:
            return ["punk"]
        case .chillout:
            return ["chillout", "lo-fi", "chill", "ambient", "relaxation" ]
        case .tradtionalMusic:
            return ["folk", "volksmusik", "polka", "marsch", "blasmusik"]
        case .news:
            return ["aktuell", "current affairs"]
        case .meditation:
            return ["meditation", "healing", "nature"]
        case .party:
            return ["party", "festival"]
        case .schlager:
            return ["schlager"]
        case .afrobeat:
            return ["afrobeat"]
        case .artistRadio:
            return ["discography"]
        default:
            return []
        }
    }

    var isLocalData: Bool {
        switch self {
        case .recent, .favorites:
            return true
        default:
            return false
        }
    }
}

extension RadioCategory {
    var iconName: String {
        switch self {
        case .local: return "location"
        case .news: return "newspaper"
        case .pop: return "music.note"
        case .schlager: return "dancer"
        case .hiphop: return "headphones"
        case .rock: return "guitars"
        case .electronic: return "bolt"
        case .dance: return "waveform"
        case .chillout: return "moon.stars"
        case .oldies: return "clock"
        case .country: return "music.mic"
        case .jazz: return "sax"
        case .classical: return "music.quarternote.3"
        case .tradtionalMusic: return "globe"
        case .alternative: return "a.circle"
        case .latin: return "globe.americas"
        case .afrobeat: return "globe.europe.africa"
        case .metal: return "metal"
        case .punk: return "punk"
        case .party: return "party.popper"
        case .meditation: return "leaf"
        case .artistRadio: return "person.wave.2"
        default: return "music.note" // fallback
        }
    }
}




