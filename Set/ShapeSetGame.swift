//
//  ShapeSetGame.swift
//  Set
//
//  Created by Mike Griebling on 2021-07-30.
//

import SwiftUI

enum Triple : Int, Chooseable {
    case one=0, two, three
    init(_ value: Int) { self.init(rawValue: value)! }
}

enum Fills { case none, solid, hatched }
enum Shapes { case capsule, diamond, sqiggle }

class ShapeSetGame: ObservableObject {

    static public var colourBlindFlag = 0
    static let themes = [
        Theme(name: "Traditional",
              colours: [.one: .orange,  .two: .green,   .three: .purple],
              shapes:  [.one: .capsule, .two: .diamond, .three: .sqiggle],
              fills:   [.one: .none,    .two: .solid,   .three: .hatched],
              number:  [.one: 1,        .two: 2,        .three: 3]),
        Theme(name: "Black & Blue",
              colours: [.one: .black,  .two:  .blue,    .three:  Color(UIColor.lightGray)],
              shapes:  [.one: .capsule, .two: .diamond, .three: .sqiggle],
              fills:   [.one: .none,    .two: .solid,   .three: .hatched],
              number:  [.one: 1,        .two: 2,        .three: 3])
    ]
    
    static func makeContent(_ state: [Triple]) -> Content {
        Content(
            colour: themes[colourBlindFlag].colours[state[0]]!,
            number: themes[colourBlindFlag].number[state[1]]!,
            fill:  themes[colourBlindFlag].fills[state[2]]!,
            shape: themes[colourBlindFlag].shapes[state[3]]!
        )
    }
    
    let cardsToStart = 12
    let cardsToMatch = Triple.allCases.count
    
    @Published private var game = SetGame<Triple,Content>(content: makeContent)
    
    typealias Card = SetGame<Triple,Content>.Card
    
    var cards : [Card]      { game.cards }
    var dealtCards : [Card] { game.dealtCards }
    var discarded : [Card]  { game.discardDeck }
    
    var noMoreCards : Bool { game.noMoreCards }
    var noMoreCheats : Bool { game.noMoreCheats }
    
    var title : String { ShapeSetGame.themes[ShapeSetGame.colourBlindFlag].name + " Set" }
    var score : String { "Score: \(game.score)" }
    var bonus : String { "Bonus: \(game.bonus)" }
    var timer : Timer?
    
    var colourFlag : Bool {
        set {
            ShapeSetGame.colourBlindFlag = newValue ? 0 : 1
            updateTheme()
        }
        get { ShapeSetGame.colourBlindFlag == 0 ? true : false }
    }
    
    init() {
        startTimer()
    }
    
    private static let capsule = RoundedRectangle(cornerRadius: Tweaks.radius)
    
    @ViewBuilder private static func strokedSymbol(shape: Shapes, colour: Color) -> some View {
        switch shape {
        case .capsule: capsule.strokeBorder(colour, lineWidth: Tweaks.lineWidth).aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .sqiggle: Squiggle().stroke(colour, lineWidth: Tweaks.lineWidth).aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .diamond: Diamond().stroke(colour, lineWidth: Tweaks.lineWidth).aspectRatio(Tweaks.aspect, contentMode: .fit)
        }
    }
    
    @ViewBuilder private static func filledSymbol(shape: Shapes, colour: Color) -> some View {
        switch shape {
        case .capsule: capsule.fill(colour).aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .sqiggle: Squiggle().fill(colour).aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .diamond: Diamond().fill(colour).aspectRatio(Tweaks.aspect, contentMode: .fit)
        }
    }
    
    @ViewBuilder private static func hatchedSymbol(shape: Shapes, colour: Color) -> some View {
        switch shape {
        case .capsule: capsule.stripes(colour: colour).aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .sqiggle: Squiggle().stripes(colour: colour).aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .diamond: Diamond().stripes(colour: colour).aspectRatio(Tweaks.aspect, contentMode: .fit)
        }
    }
    
    @ViewBuilder static func draw(_ card : Card, colour: Color) -> some View  {
        let colourOfSymbols = card.content.colour
        let shapeOfSymbols = card.content.shape
        switch card.content.fill {
        case .none:
            ZStack {
                // fill with white first so the hightlight shows better
                filledSymbol(shape: shapeOfSymbols, colour: colour)
                strokedSymbol(shape: shapeOfSymbols, colour: colourOfSymbols)
            }.animation(.none)
        case .solid:
            filledSymbol(shape: shapeOfSymbols, colour: colourOfSymbols).animation(.none)
        case .hatched:
            ZStack {
                hatchedSymbol(shape: shapeOfSymbols, colour: colourOfSymbols)
                strokedSymbol(shape: shapeOfSymbols, colour: colourOfSymbols)
            }.animation(.none)
        }
    }
    
    struct Theme {
        let name: String
        let colours: [Triple:Color]
        let shapes:  [Triple:Shapes]
        let fills:   [Triple:Fills]
        let number:  [Triple:Int]
    }
    
    struct Content {
        let colour : Color
        let number : Int
        let fill   : Fills
        let shape  : Shapes
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
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
            if self.game.selectedCards.count < self.cardsToMatch {
                self.game.decBonus()
            }
        }
    }
    
    // MARK: - Intents
    
    func choose(_ card: Card) { game.choose(card) }
    
    func dealCard(starting: Bool) { game.dealCards(number: 1, start: starting) }
    
    func cheat() { game.cheat() }
    
    func updateTheme() { game.updateTheme(content: ShapeSetGame.makeContent) }
    
    func newGame() {
        game = SetGame<Triple,Content>(content: ShapeSetGame.makeContent)
        startTimer()
    }
}

