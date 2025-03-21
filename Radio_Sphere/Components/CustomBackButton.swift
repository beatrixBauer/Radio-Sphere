//
//  CustomBackButton.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 19.03.25.
//


import SwiftUI

struct CustomBackButton: View {
    let title: String
    let foregroundColor: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: {
            dismiss()  // Zur vorherigen View zurückkehren
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


