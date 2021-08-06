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
                let matchColor = card.isMatched ? .yellow : DrawingConstants.cardColour
                let color = card.failedMatch ? Color.red : matchColor
                cardShape.fill().foregroundColor(color)
                cardShape.strokeBorder(lineWidth: card.isSelected ? 2*DrawingConstants.lineWidth : DrawingConstants.lineWidth)
                VStack {
                    ForEach([Int](1...card.content.number), id: \.self) { _ in
                        ShapeSetGame.draw(card, colour: DrawingConstants.cardColour)
                    }
                }.padding()
            }
        }.foregroundColor(backColor)
    }
    
    private struct DrawingConstants {
        static let cardColour = Color.white
        static let cornerRadius = CGFloat(10)
        static let lineWidth = CGFloat(3)
        static let opacity = 0.8
    }
}

