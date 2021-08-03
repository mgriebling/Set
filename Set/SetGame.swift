//
//  SetGame.swift
//  Set
//
//  Created by Mike Griebling on 2021-07-30.
//

import Foundation

protocol Chooseable : Equatable, CaseIterable { }

extension Chooseable {
    
    // Advance to the next value, if at the last value, the first value is used
    static public func inc(_ set: inout Self) {
        let all = Array(Self.allCases)
        if let index = all.firstIndex(of: set)  {
            let next = all.index(after: index)
            if next == all.endIndex { set = all.first! }
            else { set = all[next] }
        }
    }
    
}

struct SetGame<SetType:Chooseable> {
    
    private(set) var cards: [Card]      // dealt cards
    private      var allCards: [Card]   // full deck
    
    private var numberOfCardsToSelect : Int { SetType.allCases.count }     // this should always be true for all set game variants
    private var numberOfStateVariables : Int { SetType.allCases.count+1 }  // this should always be true for all set game variants
    
    var noMoreCards : Bool { allCards.count == 0 }
    var noMoreCheats : Bool = false
    private(set) var score = 0
    
    // Generic match that will work for any number of cards
    private func match(_ sets: [SetType]) -> Bool {
        var isEqual = true
        var isNotEqual = true
        
        // evaluate all the set variables
        for index in sets.indices {
            let next = (index+1) % sets.count
            isEqual = isEqual && sets[index] == sets[next]
            isNotEqual = isNotEqual && sets[index] != sets[next]
        }
        return isEqual || isNotEqual
    }
    
    /// Check if the indexed cards match.
    ///
    /// All three cards must satisfy *all* the following for a match
    ///  - They all have the same number or have three different numbers.
    ///  - They all have the same shape or have three different shapes.
    ///  - They all have the same shading or have three different shadings.
    ///  - They all have the same color or have three different colors.
    func match(_ shapes: [[SetType]]) -> Bool {
        return shapes[0].indices.reduce(true) {result, index in
            let combined = shapes.reduce([SetType]()) { $0 + [$1[index]] }
            return result && match(combined)
        }
    }
    
    private mutating func matchCards(_ indices: [Int]) {
        guard indices.count == numberOfCardsToSelect, matchedIndices.count == 0, failMatchIndices.count == 0 else { return }
        let allStates = indices.map { cards[$0].states }
        let matched = match(allStates)
        for index in indices {
            if matched {
                cards[index].isMatched = true
            } else {
                cards[index].failedMatch = true
            }
        }
        if matched { score += 3 }
        else { score -= 1 }
    }
    
    private mutating func replaceCards(_ indices: [Int]) {
        // Use reversed indices to delete from the bottom up
        for index in indices.reversed() {
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
            cards[index].failedMatch = false
            cards[index].isMatched = false
        }
    }
    
    private var selectedIndices : [Int] { cards.indices.filter { cards[$0].isSelected } }
    private var matchedIndices : [Int]  { cards.indices.filter { cards[$0].isMatched } }
    private var failMatchIndices : [Int]  { cards.indices.filter { cards[$0].failedMatch } }
    
    mutating fileprivate func handleMatchedCards() {
        if matchedIndices.count == numberOfCardsToSelect {
            replaceCards(matchedIndices)
        } else {
            deselectCards(selectedIndices)
        }
    }
    
    mutating func choose(_ card: Card) {
        if let chosenIndex = cards.firstIndex(where: { card.id == $0.id }) {
            if selectedIndices.count < numberOfCardsToSelect {
                cards[chosenIndex].isSelected.toggle()
            } else {
                cards[chosenIndex].isSelected = true
            }
            matchCards(selectedIndices)
            if selectedIndices.count > numberOfCardsToSelect {
                handleMatchedCards()
                cards[chosenIndex].isSelected = true
            }
        }
    }
    
    private mutating func remove(_ card: Card, from cards: [Card]) -> [Card] {
        var newCards = cards
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            newCards.remove(at: index)
        }
        return newCards
    }
    
    fileprivate mutating func findASet() -> [Card] {
        let myCards = cards
        for card1 in myCards {
            let myCards2 = remove(card1, from: myCards)
            for card2 in myCards2 {
                let myCards3 = remove(card1, from: myCards2)
                for card3 in myCards3 {
                    if match([card1.states, card2.states, card3.states]) {
                        return [card1, card2, card3]
                    }
                }
            }
        }
        return []
    }
    
    /// Cheat by providing a solution
    mutating func cheat() {
        let set = findASet()
        if set.count == numberOfCardsToSelect {
            deselectCards(selectedIndices)
            set.forEach { choose($0) }
            score -= 4
        } else {
            // No match so deal some more cards
            dealCards(number: 3)
            cheat()
            noMoreCheats = matchedIndices.count == 0
        }
    }
    
    mutating func dealCards(number: Int) {
        guard !noMoreCards else { return }
        
        // check if *numberOfCardsToSelect* cards have been matched
        if selectedIndices.count == numberOfCardsToSelect {
            handleMatchedCards()
        } else {
            // move 'number' cards to the 'dealtCards' -- ok to ask for too many
            cards.append(contentsOf: allCards.prefix(number))
            
            // remove 'number' cards from the deck -- check the number or 'removeFirst' will complain
            allCards.removeFirst(min(number, allCards.count))
        }
    }
    
    /// Uses recursion to increment all the states
    private func inc(_ states: inout [SetType]) {
        guard states.count > 0 else { return }
        let lastValue = Array(SetType.allCases).last!
        if states.first == lastValue {
            // increment the next state variable
            var newStates = Array(states.dropFirst())
            inc(&newStates)
            states = [states.first!] + newStates
        }
        SetType.inc(&states[0])
    }
    
    init(cardsToStart: Int) {
        cards = []
        allCards = []
        
        // Total number of cards
        let totalCards = Int(pow(Double(numberOfCardsToSelect), Double(numberOfStateVariables)))
        
        // creates 3⁴ = 81 cards
        var states = [SetType](repeating: SetType.allCases.first!, count: numberOfStateVariables)
        for id in 0..<totalCards {
            allCards.append(Card(states: states, id: id))
            inc(&states)
        }
        
        // shuffle the deck
        allCards.shuffle()
        
        // deal 'cardsToStart' cards to begin
        dealCards(number: cardsToStart)
    }
    
    struct Card : Identifiable {
        var isSelected = false
        var isMatched = false
        var failedMatch = false
        let states : [SetType]  // we store one SetType element for each card attribute
        let id: Int             // Identifiable compliance
    }
    
}
