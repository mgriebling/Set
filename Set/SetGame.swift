//
//  SetGame.swift
//  Set
//
//  Created by Mike Griebling on 2021-07-30.
//

import Foundation

struct SetGame<CardContent> where CardContent: Equatable {
    
    private(set) var cards: [Card]      // dealt cards
    private      var allCards: [Card]   // full deck
    
    mutating func choose(_ card: Card) {

    }
    
    mutating func dealCards(number: Int) {
        // move 'number' cards to the 'dealtCards' -- ok to ask for too many
        cards.append(contentsOf: allCards.prefix(number))
        
        // remove 'number' cards from the deck -- check the number or 'removeFirst' will complain
        allCards.removeFirst(min(number, allCards.count))
    }
    
    init(createCardContent: (Triple, Triple, Triple, Triple) -> CardContent) {
        cards = []
        allCards = []
        var id = 0
        
        // creates 3⁴ = 81 cards
        for index1 in Triple.allCases {
            for index2 in Triple.allCases {
                for index3 in Triple.allCases {
                    for index4 in Triple.allCases {
                        let content = createCardContent(index1, index2, index3, index4)
                        allCards.append(Card(content: content, id: id))
                        id += 1
                    }
                }
            }
        }
        
        // shuffle the deck
        allCards.shuffle()
        
        // deal 12 cards to start
        dealCards(number: 12)
    }
    
    struct Card : Identifiable {
        var isFaceUp = true
        var isMatched = false
        let content : CardContent
        let id: Int // Identifiable compliance
    }
    
}
