//
//  SetCardView.swift
//  Set
//
//  Created by Mike Griebling on 2021-07-31.
//

import SwiftUI

struct SetCardView: View {
    var card: SetGame<Triple,ShapeSetGame.Content>.Card
    var backColor: Color
    
    var body: some View {
        VStack {
            let cardShape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
            ZStack {
                cardShape.fill().foregroundColor(DrawingConstants.cardColour)
                cardShape.strokeBorder(lineWidth: card.isSelected ? 2*DrawingConstants.lineWidth : DrawingConstants.lineWidth)
                VStack {
                    ForEach([Int](1...card.content.number), id: \.self) { _ in
                        ShapeSetGame.draw(card, colour: DrawingConstants.cardColour)
                    }
                }.padding()
                Image(systemName: card.isMatched ? "checkmark" : "xmark")
                    .font(.system(size: DrawingConstants.xmarkSize))
                    .foregroundColor(card.isMatched ? .green : .red)
                    .opacity((card.failedMatch || card.isMatched) ? 1 : 0)
                    .shadow(radius: 10)
            }
        }.foregroundColor(backColor)
    }
    
    private struct DrawingConstants {
        static let cardColour = Color.white
        static let cornerRadius = CGFloat(10)
        static let lineWidth = CGFloat(3)
        static let opacity = 0.8
        static let xmarkSize = CGFloat(150)
    }
}

