//
//  StringCorrection.swift
//  Radio_Sphere
//  Created by Beatrix Bauer on 02.04.25.
//

import Foundation            // ← falls noch nicht vorhanden

// MARK: dient der richtigen Darstellung der Metadaten
// Handling von Sonderzeichen für die richtige Darstellung der Metadaten,
// wie Songtitel oder Künstler

extension String {

    /// Korrigiert falsche Zeichenkodierungen (Umlaute …)
    /// + trimmt führende/abschließende Leerzeichen
    func fixEncoding() -> String {
        let encodings: [String.Encoding] = [.isoLatin1, .windowsCP1252, .utf8, .ascii]

        for enc in encodings {
            if let data = self.data(using: enc),
               let decoded = String(data: data, encoding: .utf8),
               !decoded.contains("�") {
                return decoded.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // ---------------------------------------------------------------
    //  Zentrale Plausibilitäts-Prüfung für Stream-Metadaten
    // ---------------------------------------------------------------
    /// Liefert true, wenn der Text als unbrauchbare Meta-Angabe gilt
    var isInvalidMeta: Bool {
        let txt = trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // 1) leer
        if txt.isEmpty { return true }

        // 2) Platzhalter / Werbe-Flags
        let blacklist = ["true", "false", "unknown", "advertisement", "ads", "ad break"]
        if blacklist.contains(txt) { return true }

        // 3) JSON-Blöcke   { … }   oder   "key": …
        if txt.first == "{", txt.last == "}" { return true }
        if txt.range(of: #"(\"[a-z0-9_]+\")\s*:"#,
                     options: .regularExpression) != nil { return true }

        // 4) Endlos-Tokens (>20 Zeichen ohne Leerzeichen)
        if !txt.contains(" ") && txt.count > 20 { return true }

        // 5) Streaming-Header-Fragmente
        if txt.contains("gzip") { return true }

        return false
    }

}
