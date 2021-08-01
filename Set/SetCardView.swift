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
            let noOfSymbols = card.content.numberOfSymbols
            let colourOfSymbols = card.content.colourOfSymbols
            let shapeOfSymbols = card.content.shapeOfSymbols
            ZStack {
                let matchColor = card.failedMatch ? Color.red.opacity(DrawingConstants.opacity) : DrawingConstants.cardColour
                let color = card.isMatched ? .yellow.opacity(DrawingConstants.opacity) : matchColor
                cardShape.fill().foregroundColor(color)
                cardShape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
                VStack {
                    ForEach([Int](1...noOfSymbols), id: \.self) { _ in
                        switch card.content.fillOfSymbols {
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

//struct SetCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        let card = SetGame<Shapes>.Card(content: Shapes(colour: .one, shape: .one, fill: .two, number: .three), id: 100)
//        return SetCardView(card: card, backColor: Color.blue)
//    }
//}
