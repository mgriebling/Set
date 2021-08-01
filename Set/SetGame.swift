//
//  SetGame.swift
//  Set
//
//  Created by Mike Griebling on 2021-07-30.
//

import Foundation

protocol Chooseable : Equatable, CaseIterable {  }

struct SetGame<SetType:Chooseable> {
    
    private(set) var cards: [Card]      // dealt cards
    private      var allCards: [Card]   // full deck
    
    private var numberOfCardsToSelect : Int { SetType.allCases.count }     // this should always be true for all set game variants
    private var numberOfStateVariables : Int { SetType.allCases.count+1 }  // this should always be true for all set game variants
    
    var noMoreCards : Bool { allCards.count == 0 }
    
    private mutating func matchCards(_ indices: [Int]) -> Bool {
        guard indices.count == numberOfCardsToSelect else { return false }
        let contents = indices.map { cards[$0].content }
        let match = contents[0].match(a: contents[1], b: contents[2])
        for index in indices {
            cards[index].isMatched = match
        }
        return match
    }
    
    private mutating func removeCards(_ indices: [Int]) {
        cards.remove(atOffsets: IndexSet(indices))
    }
    
    private mutating func replaceCards(_ indices: [Int]) {
        for index in indices {
            if allCards.count > 0 {
                cards[index] = allCards.removeFirst()
            } else {
                cards.remove(at: index)
            }
        }
    }

    private mutating func deselectCards(_ indices: [Int]) {
        for index in indices {
            cards[index].isSelected = false
        }
    }
    
    private var selectedIndices : [Int] { cards.indices.filter { cards[$0].isSelected } }
    
    private mutating func extractedFunc(_ selectedIDs: [Int], _ chosenIndex: Array<SetGame.Card>.Index) {
        if matchCards(selectedIDs) {
            if !selectedIDs.contains(chosenIndex) {
                cards[chosenIndex].isSelected = true
                removeCards(selectedIDs)
                dealCards(number: numberOfCardsToSelect)
            }
        } else {
            deselectCards(selectedIDs)
            cards[chosenIndex].isSelected = true
        }
    }
    
    mutating func choose(_ card: Card) {
        if let chosenIndex = cards.firstIndex(where: { card.id == $0.id }) {
            let numberSelected = selectedIndices.count
            if numberSelected < numberOfCardsToSelect {
                cards[chosenIndex].isSelected.toggle()
                if selectedIndices.count == numberOfCardsToSelect && matchCards(selectedIndices) {
                    // cards are highlighted
                }
            } else if numberSelected == numberOfCardsToSelect {
                extractedFunc(selectedIndices, chosenIndex)
            }
        }
    }
    
    mutating func dealCards(number: Int) {
        guard !noMoreCards else { return }
        
        // check if *numberOfCardsToSelect* cards have been matched
        if selectedIndices.count == numberOfCardsToSelect && matchCards(selectedIndices) {
            // replace matched cards with new cards
            replaceCards(selectedIndices)
        } else {
            // move 'number' cards to the 'dealtCards' -- ok to ask for too many
            cards.append(contentsOf: allCards.prefix(number))
            
            // remove 'number' cards from the deck -- check the number or 'removeFirst' will complain
            allCards.removeFirst(min(number, allCards.count))
        }
    }
    
    init() {
        cards = []
        allCards = []
        var id = 0
        
        // creates 3⁴ = 81 cards
        for index1 in SetType.allCases {
            for index2 in SetType.allCases {
                for index3 in SetType.allCases {
                    for index4 in SetType.allCases {
                        let content = Shapes(states: [index1, index2, index3, index4])
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
        var isSelected = false
        var isMatched = false
        let content : Shapes
        let id: Int // Identifiable compliance
    }
      
    struct Shapes {
        let states : [SetType]  // we store one array element for each card attribute
        
        private func match(_ a: SetType, _ b: SetType, _ c: SetType) -> Bool {
            (a == b && b == c) || (a != b && b != c)
        }
        
        /// Check if the indexed cards match.
        ///
        /// All three cards must satisfy *all* the following for a match
        ///  - They all have the same number or have three different numbers.
        ///  - They all have the same shape or have three different shapes.
        ///  - They all have the same shading or have three different shadings.
        ///  - They all have the same color or have three different colors.
        func match(a: Shapes, b: Shapes) -> Bool {
//            var didMatch = true
            let didMatch = states.indices.reduce(true) { $0 && match(a.states[$1], b.states[$1], states[$1]) }
//            for symbol in states.indices {
//                didMatch = didMatch && match(a.states[symbol], b.states[symbol], self.states[symbol])
//            }
            return didMatch
        }
    }
    
}
