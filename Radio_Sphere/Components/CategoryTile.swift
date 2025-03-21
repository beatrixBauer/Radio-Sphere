//
//  CategoryTile.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 28.02.25.
//
import SwiftUI

struct CategoryTile: View {
    let title: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.2))
                .frame(height: 120)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .bold()
        }
    }
}
