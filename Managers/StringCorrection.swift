//
//  StringCorrection.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 22.02.25.
//
extension String {
    /// Versucht verschiedene Zeichenkodierungen, um fehlerhafte Umlaute zu korrigieren
    func fixEncoding() -> String {
        // Teste verschiedene mögliche Kodierungen
        let potentialEncodings: [String.Encoding] = [
            .isoLatin1,             // ISO-8859-1
            .windowsCP1252,         // Windows-1252
            .utf8,                  // UTF-8 (Fallback)
            .ascii                  // ASCII als letzte Instanz
        ]
        
        for encoding in potentialEncodings {
            if let data = self.data(using: encoding),
               let decodedString = String(data: data, encoding: .utf8) {
                if !decodedString.contains("�") {
                    return decodedString
                }
            }
        }
        
        // Fallback: Originalstring zurückgeben, wenn keine Kodierung passt
        return self
    }
}


