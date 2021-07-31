//
//  SetCardView.swift
//  Set
//
//  Created by Mike Griebling on 2021-07-31.
//

import SwiftUI

struct SetCardView: View {
    var card: SetGame<Shapes>.Card
    var backColor: Color
    
    var body: some View {
        VStack {
            let cardShape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
            let noOfSymbols = card.content.numberOfSymbols
            let colourOfSymbols = card.content.colourOfSymbols
            let shapeOfSymbols = card.content.shapeOfSymbols
            if card.isFaceUp {
                ZStack {
                    cardShape.fill().foregroundColor(.white)
                    cardShape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
                    VStack {
                        ForEach([Int](1...noOfSymbols), id: \.self) { _ in
                            switch card.content.fillOfSymbols {
                            case .none: ShapeSetGame.strokedSymbol(shape: shapeOfSymbols, colour: colourOfSymbols)
                            case .solid: ShapeSetGame.filledSymbol(shape: shapeOfSymbols, colour: colourOfSymbols)
                            case .hatched:
                                ZStack {
                                    ShapeSetGame.hatchedSymbol(shape: shapeOfSymbols, colour: colourOfSymbols)
                                    ShapeSetGame.strokedSymbol(shape: shapeOfSymbols, colour: colourOfSymbols)
                                }
                            }
                        }
                    }
                }
            } else if card.isMatched {
                cardShape.opacity(0)
            } else {
                cardShape.fill()
            }
        }.foregroundColor(backColor)
    }
    
    private struct DrawingConstants {
        static let cornerRadius = CGFloat(20)
        static let lineWidth = CGFloat(3)
        static let fontScale = CGFloat(0.8)
        static let opacity = 0.3
    }
}

struct SetCardView_Previews: PreviewProvider {
    static var previews: some View {
        let card = SetGame<Shapes>.Card(content: Shapes(colour: .one, shape: .one, fill: .two, number: .three), id: 100)
        return SetCardView(card: card, backColor: Color.blue)
    }
}
