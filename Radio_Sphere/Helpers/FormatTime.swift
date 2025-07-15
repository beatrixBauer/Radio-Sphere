//
//  FormatTime.swift
//  Radio Sphere
//

import Foundation

extension Int {
    /// Sekundenzahl als "mm:ss"
    var asMMSS: String {
        let m = self / 60
        let s = self % 60
        return String(format: "%02d:%02d", m, s)
    }
}

