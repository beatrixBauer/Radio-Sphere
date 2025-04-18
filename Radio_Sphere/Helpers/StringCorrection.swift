//
//  StringCorrection.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 02.04.25.
//

// MARK: dient der richtigen Darstellung der Metadaten
// Handling von Sonderzeichen für die richtige Darstellung der Metadaten, wie Songtitel oder Künstler

extension String {
    /// Versucht verschiedene Zeichenkodierungen, um fehlerhafte Umlaute zu korrigieren
    /// und trimmt anschließend führende und abschließende Leer­zeichen.
    func fixEncoding() -> String {
        let potentialEncodings: [String.Encoding] = [
            .isoLatin1,      // ISO-8859-1
            .windowsCP1252,  // Windows-1252
            .utf8,           // UTF-8
            .ascii           // ASCII
        ]

        for encoding in potentialEncodings {
            if let data = self.data(using: encoding),
               let decodedString = String(data: data, encoding: .utf8),
               !decodedString.contains("�") {
                // Hier trimmen wir führende und abschließende Leerzeichen:
                return decodedString
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        // Fallback: Originalstring trimmen, falls keine Kodierung gepasst hat
        return self
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

