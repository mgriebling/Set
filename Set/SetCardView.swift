//
//  SetCardView.swift
//  Set
//
//  Created by Mike Griebling on 2021-07-31.
//

import SwiftUI

struct SetCardView: View {
    var card: ShapeSetGame.Card
    
    var body: some View {
        GeometryReader { geometry in
            let backColour = card.isSelected ? DrawingConstants.highlightColour : DrawingConstants.outlineColour
            VStack {
                ZStack {
                    VStack {
                        ForEach([Int](1...card.content.number), id: \.self) { _ in
                            ShapeSetGame.draw(card, colour: DrawingConstants.cardColour)
                        }
                    }
                    .padding()
                    let active = card.isMatched || card.failedMatch
                    Image(systemName: card.isMatched ? "checkmark" : "xmark")
                        .opacity(active ? 1 : 0)
                        .animation(.easeInOut(duration: 1).repeat(while: active, autoreverses: true))
                        .font(Font.system(size: DrawingConstants.fontSize))
                        .scaleEffect(scale(thatFits: geometry.size))
                        .foregroundColor(card.isMatched ? .green : .red)
                        .shadow(radius: DrawingConstants.shadowRadius)
                }
            }
            .cardify(isFaceUp: card.isFaceUp)
            .foregroundColor(backColour)
        }
    }
    
    // the "scale factor" to scale our Text up so that it fits the geometry.size offered to us
    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let repeating = 100
        static let highlightColour = Color.blue
        static let outlineColour = Color.gray.opacity(0.6)
        static let cardColour = Color.white
        static let lineWidth = CGFloat(3)
        static let opacity = 0.8
        static let fontScale: CGFloat = 0.7
        static let fontSize: CGFloat = 40
        static let shadowRadius = CGFloat(10)
    }
}

