import SwiftUI

struct MarqueeText: View {
    let text: String
    let font: Font
    let speed: Double
    let delay: Double
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            Text(text)
                .font(font)
                .lineLimit(1)
                .offset(x: offset)
                .onAppear {
                    let textWidth = textWidth(text: text, font: UIFont.systemFont(ofSize: 17))
                    let containerWidth = geometry.size.width
                    
                    if textWidth > containerWidth {
                        withAnimation(Animation.linear(duration: speed).repeatForever(autoreverses: false).delay(delay)) {
                            offset = -textWidth - 50 // Platz für fließenden Übergang
                        }
                    }
                }
        }
        .frame(height: 20)
        .clipped() // Schneidet den überflüssigen Bereich ab
    }
    
    private func textWidth(text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let size = text.size(withAttributes: attributes)
        return size.width
    }
}
