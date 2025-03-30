//
//  RowBackgroundModifier.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.03.25.
//


struct RowBackgroundModifier: ViewModifier {
    let index: Int

    func body(content: Content) -> some View {
        content
            .background(background(for: index))
    }
    
    @ViewBuilder
    private func background(for index: Int) -> some View {
        if index.isMultiple(of: 2) {
            Color.gray.opacity(0.1)
        } else {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.4),
                    Color.gray.opacity(0.1)
                ]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
        }
    }
}

extension View {
    func rowBackground(index: Int) -> some View {
        self.modifier(RowBackgroundModifier(index: index))
    }
}
