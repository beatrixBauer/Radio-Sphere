//
//  RadioCategory.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 10.04.25.
//

import SwiftUICore

// MARK: Radiokategorien

enum RadioCategory: String, CaseIterable {
    
    
    case local = "Lokale Sender"
    case recent = "Zuletzt gehört"
    case favorites = "Deine Favoriten"
    case news = "Nachrichten"

    case pop = "Pop"
    case rock = "Rock"
    case jazz = "Jazz"
    case classical = "Klassik"
    case dance = "Dance"
    case oldies = "Oldies"
    case electronic = "Elektronische Musik"
    case country = "Country"
    case tradtionalMusic = "Traditionelle Musik"
    case hiphop = "Hip-Hop"
    case alternative = "Alternative"
    case latin = "Latin"
    case chillout = "Chillout"
    case meditation = "Meditation"
    case metal = "Metal"
    case punk = "Punk"
    case party = "Party"
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
            return ["chillout", "lo-fi", "chill", "ambient", "relaxation", ]
        case .tradtionalMusic:
            return ["folk", "volksmusik", "polka", "marsch", "blasmusik"]
        case .news:
            return ["aktuell", "current affairs"]
        case .meditation:
            return ["meditation", "healing", "nature"]
        case .party:
            return ["party", "festival"]
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
    var backgroundStyle: AnyShapeStyle {
        switch self {
        case .pop:
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [Color.itunespink.opacity(0.8), Color.itunesorange.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .oldies:
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [Color.darkblue.opacity(0.8), Color.itunestuerkis.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .meditation:
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [Color.itunesorange.opacity(0.8), Color.goldorange.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .tradtionalMusic:
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [Color.ituneslila.opacity(0.8), Color.darkblue.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        default:
            return AnyShapeStyle(Color.blue.opacity(0.2))
        }
    }
}


