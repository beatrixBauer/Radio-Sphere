//
//  SortMode.swift
//  Radio Sphere
//
//  Created by Beatrix Bauer on 18.04.25.
//


// SortMode.swift

import Foundation

enum SortMode {
    case grouped      // Original‑Reihenfolge (z.B. aus stationsByCategory)
    case alphaAsc     // A → Z
    case alphaDesc    // Z → A

    /// Zyklisch zum nächsten Modus wechseln
    var next: SortMode {
        switch self {
        case .grouped:   return .alphaAsc
        case .alphaAsc:  return .alphaDesc
        case .alphaDesc: return .grouped
        }
    }

    /// Label‑Text für den Button
    var label: String {
        switch self {
        case .grouped:   return "Gruppiert"
        case .alphaAsc:  return "A → Z"
        case .alphaDesc: return "Z → A"
        }
    }

    /// System‑Icon‑Name (oder dein eigenes Asset‑Name)
    var iconName: String {
        switch self {
        case .grouped:   return "arrow.up.arrow.down"
        case .alphaAsc:  return "arrow.down"       // hier ggf. dein eigener Name
        case .alphaDesc: return "arrow.up"       // ggf. ein gespiegeltes Icon
        }
    }
}
