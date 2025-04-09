//
//  CustomBackButton.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 19.04.25.
//

import SwiftUI

// MARK: personalisierter Zurück-Button zur Darstellung in gewünschter Farbe
// verwendet selectedTab, damit immer der passende Zurück-Text angezeigt wird

struct CustomBackButton: View {
    let title: String
    let foregroundColor: Color
    @Environment(\.dismiss) private var dismiss
    @Environment(\.selectedTab) private var selectedTab
    var category: RadioCategory?

    var body: some View {
        Button(action: {
            if let category = category, (category == .favorites || category == .recent) {
                selectedTab?.wrappedValue = 0
            } else {
                dismiss()
            }
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(foregroundColor)
                Text(title)
                    .foregroundColor(foregroundColor)
            }
        }
    }
}



