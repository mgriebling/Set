//
//  ShapeSetGameView.swift
//  Set
//
//  Created by Mike Griebling on 2021-07-30.
//

import SwiftUI

struct ShapeSetGameView: View {
    @ObservedObject var game: ShapeSetGame
    
    var body: some View {
        VStack {
            Text(game.title).font(.title)
            AspectVGrid(items: game.cards, aspectRatio: mainSettings.aspectRatio) { card in
                SetCardView(card: card,
                            backColor: card.isSelected ? mainSettings.highlightColour : mainSettings.outlineColour)
                    .onTapGesture { game.choose(card) }
            }
            HStack {
                Spacer()
                Button("New Game") { game.newGame() }
                Spacer()
                Button("Deal 3 Cards") { game.deal3() }.opacity(game.noMoreCards ? mainSettings.ghostedOpacity : 1.0)
                Spacer()
            }
        }
    }
    
    private struct mainSettings {
        static let highlightColour = Color.blue
        static let outlineColour = Color.gray.opacity(0.6)
        static let ghostedOpacity = 0.3
        static let aspectRatio = CGFloat(2.0/3.0)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = ShapeSetGame()
        ShapeSetGameView(game: game).preferredColorScheme(.dark)
        ShapeSetGameView(game: game).preferredColorScheme(.light)
    }
}
