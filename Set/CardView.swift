//
//  CardView.swift
//  Memorize-UIKit
//
//  Created by Mike Griebling on 2021-07-30.
//

import SwiftUI

struct CardView: View {
//    var card: EmojiMemoryGame.Card
    var background: Color = .white
    var useGradient = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let cardShape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                if card.isFaceUp {
                    cardShape.fill().foregroundColor(background.opacity(DrawingConstants.opacity))
                    cardShape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
                    Text(card.content).font(font(in: geometry.size))
                } else if card.isMatched {
                    cardShape.opacity(0)
                } else {
                    if useGradient {
                        cardShape.fill(LinearGradient(gradient: Gradient(colors: [.white, background]), startPoint: .top, endPoint: .bottom))
                    } else {
                        cardShape.fill()
                    }
                }
            }
        }
    }
    
    private func font(in size: CGSize) -> Font {
        Font.system(size: 0.8 * min(size.width, size.height))
    }
    
    private struct DrawingConstants {
        static let cornerRadius = CGFloat(20)
        static let lineWidth = CGFloat(3)
        static let fontScale = CGFloat(0.8)
        static let opacity = 0.3
    }
}
