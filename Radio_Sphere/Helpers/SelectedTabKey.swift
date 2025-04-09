//
//  SelectedTabKey.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 21.04.25.
//
import SwiftUI

// MARK: Liefert dem Custom-BackButton den passenden Pfad
// selectedTagKey wird zur Environment-Variable gemacht, die dann von Custom-BackButton verwendet werden kann

private struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<Int>? = nil
}

extension EnvironmentValues {
    var selectedTab: Binding<Int>? {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}
