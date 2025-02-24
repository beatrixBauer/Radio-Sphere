//
//  StringCorrection.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 22.02.25.
//
import Foundation

extension String {
    /// Korrigiert Zeichenkodierungsfehler (ISO-8859-1 → UTF-8), um falsche Umlaute zu fixen
    func fixEncoding() -> String {
        guard let data = self.data(using: .isoLatin1) else { return self }
        return String(data: data, encoding: .utf8) ?? self
    }
}

