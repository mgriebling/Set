//
//  SetGame.swift
//  Set
//
//  Created by Mike Griebling on 2021-07-30.
//

import Foundation

protocol Chooseable : Equatable, CaseIterable {
    init(_ value: Int)
}

struct SetGame<SetType:Chooseable, Content> {
    
    private(set) var cards: [Card]        // all cards
    private(set) var dealtCards: [Card]   // cards in play
    private(set) var discardDeck: [Card]  // discarded cards
    
    private var numberOfCardsToSelect : Int { SetType.allCases.count }     // this should always be true for all set game variants
    private var numberOfStateVariables : Int { SetType.allCases.count+1 }  // this should always be true for all set game variants
    
    var noMoreCards : Bool { cards.count == 0 }
    var noMoreCheats : Bool = false
    
    private(set) var score = 0
    private(set) var bonus = 0
    
    public let timeToMatch = 10
    
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
    
    private mutating func matchCards(_ cards: [Card]) {
        guard cards.count == numberOfCardsToSelect, matchedCards.count == 0, failMatchCards.count == 0 else { return }
        let allStates = cards.map { $0.states }
        let matched = match(allStates)
        for card in cards {
            if matched {
                dealtCards[card].isMatched = true
            } else {
                dealtCards[card].failedMatch = true
            }
        }
        if matched {
            score += 3+bonus
            resetBonus()
        } else {
            score -= 1+bonus
        }
    }
    
    private mutating func deleteCards(_ cards: [Card]) {
        // Use reversed indices to delete from the bottom up
        for var card in cards {
            dealtCards.remove(card)
            deselectCard(&card)
            discardDeck.insert(card, at: 0) // add to top of deleted cards
        }
    }

    private func deselectCard(_ card: inout Card) {
        card.isSelected = false
        card.failedMatch = false
        card.isMatched = false
    }
    
    private mutating func deselectCards(_ cards: [Card]) {
        for card in cards {
            deselectCard(&dealtCards[card])
        }
    }
    
    var selectedCards           : [Card] { dealtCards.filter { $0.isSelected } }
    private  var matchedCards   : [Card] { dealtCards.filter { $0.isMatched } }
    private  var failMatchCards : [Card] { dealtCards.filter { $0.failedMatch } }
    
    mutating fileprivate func handleMatchedCards() -> Bool {
        if matchedCards.count == numberOfCardsToSelect {
            let matched = matchedCards
            deselectCards(selectedCards)
            deleteCards(matched)
            return true
        } else {
            deselectCards(selectedCards)
            return false
        }
    }
    
    public mutating func resetBonus() {  bonus = timeToMatch }
    public mutating func decBonus()   { if bonus > 0 { bonus -= 1 } }
    
    mutating func choose(_ card: Card) {
        if selectedCards.count < numberOfCardsToSelect {
            dealtCards[card].isSelected.toggle()
        } else {
            dealtCards[card].isSelected = true
        }
        matchCards(selectedCards)
        if selectedCards.count > numberOfCardsToSelect {
            if handleMatchedCards() {
                dealCards(number: numberOfCardsToSelect)
            }
            dealtCards[card].isSelected = true
        }
    }
    
    private mutating func remove(_ card: Card, from cards: [Card]) -> [Card] {
        var newCards = cards
        newCards.remove(card)
        return newCards
    }
    
    fileprivate mutating func findASet() -> [Card] {
        let myCards = dealtCards
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
            deselectCards(selectedCards)
            set.forEach { choose($0) }
            score -= 4+bonus
        } else {
            // No match so deal some more cards
            dealCards(number: 3)
            cheat()
            noMoreCheats = matchedCards.count == 0
        }
    }
    
    mutating func dealCards(number: Int, start: Bool = false) {
        guard !noMoreCards else { return }
        
        // penalize the user for picking more cards when a set was available
        if !start && findASet().count > 0 && matchedCards.count == 0 {
            score -= 1+bonus
        }
        
        // check if *numberOfCardsToSelect* cards have been matched
        if selectedCards.count == numberOfCardsToSelect {
            _ = handleMatchedCards()
        }
        
        // move 'number' cards to the 'dealtCards' -- ok to ask for too many
        var newCards = cards.prefix(number)
        newCards.forEach { newCards[$0].isFaceUp = true }
        dealtCards.append(contentsOf: newCards)
        
        // remove 'number' cards from the deck -- check the number or 'removeFirst' will complain
        cards.removeFirst(min(number, cards.count))
    }
    
    mutating func updateTheme(content: ([SetType]) -> (Content)) {
        dealtCards.forEach { dealtCards[$0].content = content($0.states) }    // fix the dealt cards
        cards.forEach { cards[$0].content = content($0.states) }              // fix the undealt cards
        discardDeck.forEach { discardDeck[$0].content = content($0.states) }  // fix the discards
    }
    
    /// Translates the *id* to a unique set of card *states*
    private func state(_ id: Int) -> [SetType] {
        var divisor = 1
        var states = [SetType]()
        for _ in 0..<numberOfStateVariables {
            states.append(SetType((id / divisor) % numberOfCardsToSelect))
            divisor *= numberOfCardsToSelect
        }
        return states
    }
    
    init(content: ([SetType]) -> (Content)) {
        cards = []
        dealtCards = []
        discardDeck = []
        
        // Total number of cards
        let totalCards = Int(pow(Double(numberOfCardsToSelect), Double(numberOfStateVariables)))
        
        // creates 3⁴ = 81 cards
        for id in 0..<totalCards {
            let states = state(id)
            cards.append(Card(states: states, content: content(states), id: id))
        }

        // shuffle the deck
        cards.shuffle()
    }
    
    struct Card : Identifiable {
        var isSelected = false
        var isMatched = false
        var failedMatch = false
        var isFaceUp = false
        fileprivate let states : [SetType] // we store one SetType element for each card attribute
        var content : Content
        let id: Int                        // Identifiable compliance
    }
    
}
