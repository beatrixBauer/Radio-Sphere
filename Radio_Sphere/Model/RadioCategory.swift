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
    
    
    //Anzeigenamen für den Navigationtitle in der StationView
    
    var displayName: String {
        switch self {
        case .pop: return "Pop-Sender"
        case .rock: return "Rock-Sender"
        case .jazz: return "Jazz-Sender"
        case .classical: return "Klassik-Sender"
        case .dance: return "Dance-Sender"
        case .electronic: return "Elektronische Musik"
        case .local: return "Lokale Sender"
        case .recent: return "Zuletzt gehört"
        case .favorites: return "Deine Favoriten"
        case .news: return "Nachrichten-Sender"
        case .country: return "Country-Sender"
        case .hiphop: return "Hip-Hop-Sender"
        case .alternative: return "Alternative-Sender"
        case .oldies: return "Oldies"
        case .latin: return "Latin"
        case .metal: return "Metal"
        case .punk: return "Punk"
        case .tradtionalMusic: return "Volksmusik"
        case .chillout: return "Chillout"
        case .meditation: return "Meditation"
        case .party: return "Party"
        case .artistRadio: return "Künstler-Radio"
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


