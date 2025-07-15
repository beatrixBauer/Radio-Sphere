//
//  SizeHandler.swift
//  Radio Sphere
//

import UIKit

extension UIDevice {
    /// true, wenn das aktuelle Fenster eine Notch oder Dynamic Island hat
    var hasNotchAtWindowLevel: Bool {
        let topInset = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first?
            .safeAreaInsets
            .top ?? 0
        return topInset >= 44
    }

    /// true, wenn es sich um ein 12/13 mini handelt (Notch + schmale Breite)
    var isMiniNotch: Bool {
        guard hasNotchAtWindowLevel else { return false }
        // Breite im Portrait: 375 pt
        let w = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        return w <= 375
    }

    /// true für Standard‑Notch‑Geräte (X/11/12/13/14/15/16‑Serie)
    var isMediumNotch: Bool {
        guard hasNotchAtWindowLevel, !isMiniNotch else { return false }
        let w = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        // Breite zwischen 376 und 414 pt
        return (w > 375 && w <= 414)
    }

    /// true für Plus/Max/Ultra (Notch + breite Breite)
    var isLargeNotch: Bool {
        guard hasNotchAtWindowLevel else { return false }
        let w = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        return w > 414
    }
}

