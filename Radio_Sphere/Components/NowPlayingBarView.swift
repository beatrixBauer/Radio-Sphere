//
//  NowPlayingBarView.swift
//  Radio_Sphere
//

import SwiftUI

private let numBars = 8
private let spacerWidthRatio: CGFloat = 0.2
private let barWidthScaleFactor = 1 / (CGFloat(numBars) + CGFloat(numBars - 1) * spacerWidthRatio)

// MARK: animierte Balken-Anzeige für die PlayerView
// visualisiert den Player-Status

struct NowPlayingBarView: View {
    @State private var animating = false

    var body: some View {
        GeometryReader { geo in
            let barWidth = geo.widthScaled(barWidthScaleFactor)
            let spacerWidth = barWidth * spacerWidthRatio
            HStack(spacing: spacerWidth) {
                ForEach(0..<numBars, id: \.self) { index in
                    Bar(
                        minHeightFraction: 0.1,
                        maxHeightFraction: barMaxHeight(for: index),
                        completion: animating ? 1 : 0
                    )
                    .fill(Color.white.opacity(0.8))
                    .frame(width: barWidth)
                    .animation(createAnimation(), value: animating)
                }
            }
        }
        .onAppear {
            animating = true
        }
    }

    /// Liefert für die Mitte größere Werte, außen kleinere – sinusförmig von 0.4 bis 0.8
    private func barMaxHeight(for index: Int) -> CGFloat {
        let t = Double(index) / Double(numBars - 1)         // t = 0 ... 1
        let curve = 0.4 + 0.6 * sin(.pi * t)                // Werte zwischen 0.4 (außen) und 0.8 (Mitte)
        return CGFloat(curve)
    }

    private func createAnimation() -> Animation {
        Animation
            .easeInOut(duration: 0.5 + Double.random(in: -0.2...0.2))
            .repeatForever(autoreverses: true)
            .delay(Double.random(in: 0...0.75))
    }
}

// Erweiterung für GeometryProxy
extension GeometryProxy {
    func widthScaled(_ scale: CGFloat) -> CGFloat {
        self.size.width * scale
    }
}

private struct Bar: Shape {
    private let minHeightFraction: CGFloat
    private let maxHeightFraction: CGFloat
    var completion: CGFloat

    var animatableData: CGFloat {
        get { completion }
        set { completion = newValue }
    }

    init(minHeightFraction: CGFloat, maxHeightFraction: CGFloat, completion: CGFloat) {
        self.minHeightFraction = minHeightFraction
        self.maxHeightFraction = maxHeightFraction
        self.completion = completion
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let heightFraction = minHeightFraction + (maxHeightFraction - minHeightFraction) * completion
        let barHeight = rect.height * heightFraction
        let barRect = CGRect(x: 0, y: rect.height - barHeight, width: rect.width, height: barHeight)
        path.addRect(barRect)
        return path
    }
}

#Preview {
    NowPlayingBarView()
        .frame(width: 50, height: 50)
        .preferredColorScheme(.dark)
}
