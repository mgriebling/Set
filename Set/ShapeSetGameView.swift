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
        ScrollView {
            VStack {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                    ForEach(game.cards) { card in
                        SetCardView(card: card, backColor: Color.blue)
                            .aspectRatio(2/3, contentMode: .fit)
                    }
                }
            }.padding()
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
