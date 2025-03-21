//
//  NavigationBarBackButtonModifier.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 17.03.25.
//


import SwiftUI

struct NavigationBarAppearanceModifier: ViewModifier {
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black // Hintergrund schwarz oder anpassbar
        appearance.titleTextAttributes = [.foregroundColor: UIColor.clear] // Titel ausblenden
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.clear] // Großer Titel ebenfalls ausblenden
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white] // ✅ Weißer Back-Button-Text
        UINavigationBar.appearance().tintColor = .white // Weißes Chevron `<`
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    func body(content: Content) -> some View {
        content
    }
}
