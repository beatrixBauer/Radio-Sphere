import Foundation

enum RadioCategory: String, CaseIterable {
    case pop = "Popsender"
    case rock = "Rocksender"
    case jazz = "Jazzsender"
    case local = "Lokale Sender"
    case recent = "Zuletzt gehört"
    case favorites = "Deine Favoriten"

    var tag: String? {
        switch self {
        case .pop: return "pop"
        case .rock: return "rock"
        case .jazz: return "jazz"
        default: return nil
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
