//
//  CountryPickerHelper.swift
//  Radio Sphere
//


struct CountryPickerHelper {
    // Ländermappings, um lange Namen zu kürzen
    
    static let countryDisplayNames: [String: String] = [
        "Ascension And Tristan Da Cunha Saint Helena": "St. Helena",
        "Bolivarian Republic of Venezuela": "Venezuela",
        "Bosnia And Herzegovina": "Bosnia & Herzegovina",
        "British Indian Ocean Territory": "BIOT",
        "British Virgin Islands": "BVI",
        "Coted Ivoire": "Ivory Coast",
        "Federated States Of Micronesia": "Micronesia",
        "Islamic Republic Of Iran": "Iran",
        "Republic Of North Macedonia": "North Macedonia",
        "State Of Palestine": "Palestine",
        "Taiwan, Republic Of China": "Taiwan",
        "The Central African Republic": "Central African Republic",
        "The Democratic Peoples Republic Of Korea": "North Korea",
        "The Democratic Republic Of The Congo": "DR Congo",
        "The Gambia": "Gambia",
        "The Dominican Republic": "Dominican Republic",
        "The Falkland Islands Malvinas": "Falkland Islands",
        "The Lao Peoples Democratic Republic": "Laos",
        "The Republic Of Korea": "South Korea",
        "The Republic Of Moldova": "Moldova",
        "Saint Kitts And Nevis": "St. Kitts & Nevis",
        "Saint Pierre And Miquelon": "St. Pierre & Miquelon",
        "Sao Tome And Principe": "São Tomé & Príncipe",
        "Svalbard And Jan Mayen": "Svalbard",
        "The French Southern Territories": "French Southern Lands",
        "The Saint Lucia": "St. Lucia",
        "The Saint Vincent And The Grenadines": "St. Vincent & Grenadines",
        "The Seychelles": "Seychelles",
        "The Solomon Islands": "Solomon Islands",
        "The Russian Federation": "Russia",
        "The Sudan": "Sudan",
        "The Turks And Caicos Islands": "Turks & Caicos Islands",
        "The United Arab Emirates": "United Arab Emirates",
        "The United Kingdom Of Great Britain And Northern Ireland": "UK",
        "The United States Minor Outlying Islands": "US Minor Outlying Islands",
        "The United States Of America": "USA",
        "United Republic Of Tanzania": "Tanzania"

        
    ]
    
    /// Diese Funktion liefert den angezeigten (gekürzten) Ländernamen:
    static func displayName(for country: String) -> String {
        // Prüfe zunächst, ob es eine exakte Übereinstimmung gibt:
        if let shortened = countryDisplayNames[country] {
            return shortened
        }
        // Andernfalls prüfe, ob der übergebene Ländername einen der Schlüssel enthält.
        // Damit kannst du z. B. auch Varianten abdecken, in denen dem Originaltext noch Zusätze vorstehen.
        let lowerCountry = country.lowercased()
        for (fullName, shortName) in countryDisplayNames {
            if lowerCountry.contains(fullName.lowercased()) {
                return shortName
            }
        }
        // Falls keine Sonderbehandlung greift, wird der Originalname zurückgegeben.
        return country
    }
}
