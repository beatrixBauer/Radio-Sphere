//
//  CategoryTile.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 12.04.25.
//

import SwiftUI


// MARK: Ansicht Kategorien-Kachel

struct CategoryTile<BackgroundStyle: ShapeStyle>: View {
    let title: String
    let background: BackgroundStyle

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(background)
                .frame(height: 120)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .bold()
        }
    }
}


