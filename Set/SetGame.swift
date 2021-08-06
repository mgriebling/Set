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
    
    private(set) var cards: [Card]      // dealt cards
    private      var allCards: [Card]   // full deck
    
    private var numberOfCardsToSelect : Int { SetType.allCases.count }     // this should always be true for all set game variants
    private var numberOfStateVariables : Int { SetType.allCases.count+1 }  // this should always be true for all set game variants
    
    var noMoreCards : Bool { allCards.count == 0 }
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
        if matched {
            score += 3+bonus
            resetBonus()
        } else {
            score -= 1+bonus
        }
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
    
    public var selectedCards : Int { selectedIndices.count }
    
    mutating fileprivate func handleMatchedCards() {
        if selectedCards == numberOfCardsToSelect {
            replaceCards(matchedIndices)
        } else {
            deselectCards(selectedIndices)
        }
    }
    
    public mutating func resetBonus() {  bonus = timeToMatch }
    public mutating func decBonus()   { if bonus > 0 { bonus -= 1 } }
    
    mutating func choose(_ card: Card) {
        if let chosenIndex = cards.firstIndex(where: { card.id == $0.id }) {
            if selectedCards < numberOfCardsToSelect {
                cards[chosenIndex].isSelected.toggle()
            } else {
                cards[chosenIndex].isSelected = true
            }
            matchCards(selectedIndices)
            if selectedCards > numberOfCardsToSelect {
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
            score -= 4+bonus
        } else {
            // No match so deal some more cards
            dealCards(number: 3)
            cheat()
            noMoreCheats = matchedIndices.count == 0
        }
    }
    
    mutating func dealCards(number: Int) {
        guard !noMoreCards else { return }
        
        // penalize the user for picking more cards when a set was available
        if findASet().count > 0 && matchedIndices.count == 0 {
            score -= 1+bonus
        }
        
        // check if *numberOfCardsToSelect* cards have been matched
        if selectedCards == numberOfCardsToSelect {
            handleMatchedCards()
        } else {
            // move 'number' cards to the 'dealtCards' -- ok to ask for too many
            cards.append(contentsOf: allCards.prefix(number))
            
            // remove 'number' cards from the deck -- check the number or 'removeFirst' will complain
            allCards.removeFirst(min(number, allCards.count))
        }
    }
    
    mutating func updateTheme(content: ([SetType]) -> (Content)) {
        cards.indices.forEach { cards[$0].content = content(cards[$0].states) }          // fix the dealt cards
        allCards.indices.forEach { allCards[$0].content = content(allCards[$0].states) } // fix the undealt cards
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
    
    init(cardsToStart: Int, content: ([SetType]) -> (Content)) {
        cards = []
        allCards = []
        
        // Total number of cards
        let totalCards = Int(pow(Double(numberOfCardsToSelect), Double(numberOfStateVariables)))
        
        // creates 3⁴ = 81 cards
        for id in 0..<totalCards {
            let states = state(id)
            allCards.append(Card(states: states, content: content(states), id: id))
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
        fileprivate let states : [SetType] // we store one SetType element for each card attribute
        var content : Content
        let id: Int                        // Identifiable compliance
    }
    
}
