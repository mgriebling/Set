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
            HStack {
                Text(game.score).bold().opacity(0).padding(.horizontal)  // just center the title
                Spacer()
                Text(game.title)
                Spacer()
                Text(game.score).bold().padding(.horizontal)
            }
            AspectVGrid(items: game.cards, aspectRatio: mainSettings.aspectRatio) { card in
                SetCardView(card: card,
                            backColor: card.isSelected ? mainSettings.highlightColour : mainSettings.outlineColour)
                    .onTapGesture { game.choose(card) }
            }
            HStack {
                Button("New Game") { game.newGame() }
                Spacer()
                Button("Deal 3 Cards") { game.deal3() }.opacity(game.noMoreCards ? mainSettings.ghostedOpacity : 1.0)
                Spacer()
                Button("Cheat") { game.cheat() }.opacity(game.noMoreCheats ? mainSettings.ghostedOpacity : 1.0)
            }.padding(.horizontal)
        }
        .font(.title)
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
