//
//  ShapeSetGame.swift
//  Set
//
//  Created by Mike Griebling on 2021-07-30.
//

import SwiftUI

enum Triple : Int, Chooseable {

    case one=0, two, three
    
    init(_ value: Int) {
        self.init(rawValue: value)!
    }
    
}

extension SetGame.Card {
    var numberOfSymbols : Int                 { ShapeSetGame.theme.number[self.states[0] as! Triple]! }
    var colourOfSymbols : Color               { ShapeSetGame.theme.colours[self.states[1]  as! Triple]! }
    var shapeOfSymbols  : ShapeSetGame.Shapes { ShapeSetGame.theme.shapes[self.states[2]  as! Triple]! }
    var fillOfSymbols   : ShapeSetGame.Fills  { ShapeSetGame.theme.fills[self.states[3]  as! Triple]! }
}

class ShapeSetGame: ObservableObject {

    enum Fills { case none, solid, hatched }
    enum Shapes { case capsule, diamond, sqiggle }
    
    static let theme =
        Theme(name: "Traditional",
              colours: [.one: .orange,  .two: .green,   .three: .purple],
              shapes:  [.one: .capsule, .two: .diamond, .three: .sqiggle],
              fills:   [.one: .none,    .two: .solid,   .three: .hatched],
              number:  [.one: 1,        .two: 2,        .three: 3])
    
    static let cardsToStart = 12
    
    @Published private var game = SetGame<Triple>(cardsToStart: cardsToStart)
    
    var cards : [SetGame<Triple>.Card] { game.cards }
    
    var noMoreCards : Bool { game.noMoreCards }
    var noMoreCheats : Bool { game.noMoreCheats }
    var title : String { ShapeSetGame.theme.name + " Set" }
    var score : String { "Score: \(game.score)" }
    var bonus : String { "Bonus: \(game.bonus)" }
    var timer : Timer?
    
    init() {
        startTimer()
    }
    
    private static let capsule = RoundedRectangle(cornerRadius: Tweaks.radius)
    
    @ViewBuilder static func strokedSymbol(shape: Shapes, colour: Color) -> some View {
        switch shape {
        case .capsule: capsule.strokeBorder(colour, lineWidth: Tweaks.lineWidth).aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .sqiggle: Squiggle().stroke(colour, lineWidth: Tweaks.lineWidth).aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .diamond: Diamond().stroke(colour, lineWidth: Tweaks.lineWidth).aspectRatio(Tweaks.aspect, contentMode: .fit)
        }
    }
    
    @ViewBuilder static func filledSymbol(shape: Shapes, colour: Color) -> some View {
        switch shape {
        case .capsule: capsule.fill(colour).aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .sqiggle: Squiggle().fill(colour).aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .diamond: Diamond().fill(colour).aspectRatio(Tweaks.aspect, contentMode: .fit)
        }
    }
    
    @ViewBuilder static func hatchedSymbol(shape: Shapes, colour: Color) -> some View {
        switch shape {
        case .capsule: capsule.stripes(colour: colour).aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .sqiggle: Squiggle().stripes(colour: colour).aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .diamond: Diamond().stripes(colour: colour).aspectRatio(Tweaks.aspect, contentMode: .fit)
        }
    }
    
    struct Theme {
        let name: String
        let colours: [Triple:Color]
        let shapes:  [Triple:Shapes]
        let fills:   [Triple:Fills]
        let number:  [Triple:Int]
    }
    
    // MARK: - Tweaking constants
    struct Tweaks {
        static let lineWidth = CGFloat(3)
        static let radius = CGFloat(150)
        static let aspect = CGFloat(2.0/1.0)
    }
    
    private func startTimer() {
        timer?.invalidate()
        game.resetBonus()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.game.selectedCards < 3 {
                self.game.decBonus()
            }
        }
    }
    
    // MARK: - Intents
    
    func choose(_ card: SetGame<Triple>.Card) { game.choose(card) }
    
    func deal3() { game.dealCards(number: 3) }
    
    func cheat() { game.cheat() }
    
    func newGame() {
        game = SetGame<Triple>(cardsToStart: ShapeSetGame.cardsToStart)
        startTimer()
    }
}

