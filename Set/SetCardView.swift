//
//  SetCardView.swift
//  Set
//
//  Created by Mike Griebling on 2021-07-31.
//

import SwiftUI

struct SetCardView: View {
    var card: SetGame<Triple>.Card
    var backColor: Color
    
    var body: some View {
        VStack {
            let cardShape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
            let noOfSymbols = card.numberOfSymbols
            let colourOfSymbols = card.colourOfSymbols
            let shapeOfSymbols = card.shapeOfSymbols
            ZStack {
                let matchColor = card.isMatched ? .yellow : DrawingConstants.cardColour
                let color = card.failedMatch ? Color.red : matchColor
                cardShape.fill().foregroundColor(color)
                cardShape.strokeBorder(lineWidth: card.isSelected ? 2*DrawingConstants.lineWidth : DrawingConstants.lineWidth)
                VStack {
                    ForEach([Int](1...noOfSymbols), id: \.self) { _ in
                        switch card.fillOfSymbols {
                        case .none:
                            ZStack {
                                // fill with white first so the hightlight shows better
                                ShapeSetGame.filledSymbol(shape: shapeOfSymbols, colour: DrawingConstants.cardColour)
                                ShapeSetGame.strokedSymbol(shape: shapeOfSymbols, colour: colourOfSymbols)
                            }
                        case .solid:
                            ShapeSetGame.filledSymbol(shape: shapeOfSymbols, colour: colourOfSymbols)
                        case .hatched:
                            ZStack {
                                ShapeSetGame.hatchedSymbol(shape: shapeOfSymbols, colour: colourOfSymbols)
                                ShapeSetGame.strokedSymbol(shape: shapeOfSymbols, colour: colourOfSymbols)
                            }
                        }
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

