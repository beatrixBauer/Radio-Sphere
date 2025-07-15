//
//  CountryPickerSheet.swift
//  Radio Sphere
//


// MARK: Sheet zur Länderauswahl innerhalb der Genre-Kategorie

import SwiftUI

struct CountryPickerSheet: View {
    let countries: [String]
    @Binding var selectedCountry: String
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""

    // Filtert Länder anhand der Suche
    private var filtered: [String] {
        if searchText.isEmpty { return countries }
        return countries.filter {
            $0.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // immer „Alle“ ganz oben
                Button("Alle") {
                    selectedCountry = "Alle"
                    dismiss()
                }
                .foregroundColor(selectedCountry == "Alle" ? .accentColor : .primary)

                ForEach(filtered, id: \.self) { country in
                    Button(country) {
                        selectedCountry = country
                        dismiss()
                    }
                    .foregroundColor(selectedCountry == country ? .accentColor : .primary)
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Land suchen")
            .navigationTitle("Land wählen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }
}
