//
//  NowPlayingBarView.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 25.04.25.
//

import SwiftUI

private let numBars = 5
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
                ForEach(0..<numBars, id: \.self) { _ in
                    Bar(minHeightFraction: 0.1, maxHeightFraction: 1, completion: animating ? 1 : 0)
                        .fill(Color.white)
                        .frame(width: barWidth)
                        .animation(createAnimation(), value: animating)
                }
            }
        }
        .onAppear {
            animating = true
        }
    }

    private func createAnimation() -> Animation {
        Animation
            .easeInOut(duration: 0.5 + Double.random(in: -0.3...0.3))
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
