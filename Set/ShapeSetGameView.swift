//
//  ShapeSetGameView.swift
//  Set
//
//  Created by Mike Griebling on 2021-07-30.
//

import SwiftUI

struct ShapeSetGameView: View {
    @ObservedObject var game: ShapeSetGame
    
    // a token which provides a namespace for the id's used in matchGeometryEffect
    @Namespace private var dealingNamespace
    
    private func zIndex(of card: ShapeSetGame.Card, in deck: [ShapeSetGame.Card]) -> Double {
        -Double(deck.index(matching: card) ?? 0)
    }
    
    private func dealAnimation(for index: Int, totalCards: Int, matched: Bool) -> Animation {
        let delay = Double(index+1) * (mainSettings.totalDealDuration / Double(totalCards+1))
        let extra = matched ? 1.0 : 0.0
        return Animation.easeInOut(duration: mainSettings.dealDuration).delay(delay+extra)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HStack {
                    Text(game.bonus).bold().padding(.horizontal)
                    Spacer()
                    Text(game.title)
                    Spacer()
                    Text(game.score).bold().padding(.horizontal)
                }
                gameBody
                HStack {
                    restart; Spacer()
                    cheat; Spacer()
                    colour
                }.padding(.horizontal)
            }
            HStack {
                Spacer()
                deckBody
                Spacer()
                discardDeck
                Spacer()
            }
        }
        .onAppear() {
            dealCards(game.cardsToStart, starting: true)
        }
    }
    
    var restart: some View {
        Button("Restart") {
            withAnimation {
                game.newGame()
            }
            dealCards(game.cardsToStart, starting: true)
        }
    }
    
    var cheat: some View {
        Button("Cheat") {
            withAnimation {
                game.cheat()
            }
        }
        .opacity(game.noMoreCheats ? mainSettings.ghostedOpacity : 1)
    }
    
    var colour: some View {
        Toggle("Colour", isOn: $game.colourFlag).animation(.none)
            .fixedSize().foregroundColor(.accentColor)
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.dealtCards, aspectRatio: mainSettings.aspectRatio) { card in
            SetCardView(card: card)
                .matchedGeometryEffect(id: card.id, in: dealingNamespace)
//                .transition(AnyTransition.asymmetric(insertion: .flipFaceUp, removal: .identity))
                .padding(mainSettings.padding)
                .zIndex(zIndex(of: card, in: game.dealtCards))
                .onTapGesture {
                    withAnimation {
                        game.choose(card)
                    }
                }
        }
    }
    
    // deck used to deal out cards
    var deckBody: some View {
        ZStack {
            ForEach(game.cards) { card in
                SetCardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .flipFaceUp))
                    .zIndex(zIndex(of: card, in: game.cards))
            }
        }
        .frame(width: mainSettings.undealtWidth, height: mainSettings.undealtHeight)
        .foregroundColor(mainSettings.colour)
        .onTapGesture {
            dealCards(game.cardsToMatch, starting: false)
        }
    }
    
    func dealCards(_ number: Int, starting: Bool) {
        let matched = game.matchedCards.count > 0
        for index in 0..<number {
            withAnimation(dealAnimation(for: index, totalCards: number, matched: matched)) {
                game.dealCard(starting: starting)
            }
        }
    }
    
    // deck used to deal out cards
    var discardDeck: some View {
        ZStack {
            ForEach(game.discarded) { card in
                SetCardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .zIndex(zIndex(of: card, in: game.discarded))
                    .animation(.easeInOut(duration: mainSettings.dealDuration))
            }
        }
        .frame(width: mainSettings.undealtWidth, height: mainSettings.undealtHeight)
        .foregroundColor(mainSettings.colour)
    }
    
    private struct mainSettings {
        static let padding = CGFloat(4)
        static let colour = Color.blue
        static let ghostedOpacity = 0.3
        static let aspectRatio = CGFloat(2.0/3.0)
        static let totalDealDuration = Double(10)
        static let dealDuration = Double(1)
        static let undealtHeight = CGFloat(90)
        static let undealtWidth = undealtHeight * aspectRatio
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = ShapeSetGame()
        ShapeSetGameView(game: game).preferredColorScheme(.dark)
        ShapeSetGameView(game: game).preferredColorScheme(.light)
    }
}
