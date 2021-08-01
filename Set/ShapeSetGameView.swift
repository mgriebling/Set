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
            AspectVGrid(items: game.cards, aspectRatio: 2/3) { card in
                SetCardView(card: card,
                            backColor: card.isSelected ? .blue : .gray.opacity(0.6))
                    .onTapGesture { game.choose(card) }
            }
            HStack {
                Spacer()
                Button("New Game") { game.newGame() }
                Spacer()
                Button("Deal 3 Cards") { game.deal3() }.opacity(game.noMoreCards ? 0.3 : 1.0)
                Spacer()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = ShapeSetGame()
        ShapeSetGameView(game: game).preferredColorScheme(.dark)
        ShapeSetGameView(game: game).preferredColorScheme(.light)
    }
}
