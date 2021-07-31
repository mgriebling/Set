//
//  ShapeSetGame.swift
//  Set
//
//  Created by Mike Griebling on 2021-07-30.
//

import SwiftUI

enum Triple : Equatable, CustomStringConvertible, CaseIterable {
    case one, two, three
    
    var description: String {
        switch self {
        case .one: return "one"
        case .two: return "two"
        case .three: return "three"
        }
    }
}

struct Shapes : Equatable {
    let colour : Triple
    let shape : Triple
    let fill : Triple
    let number : Triple
    
    var numberOfSymbols : Int { ShapeSetGame.theme.number[self.number]! }
    var colourOfSymbols : Color { ShapeSetGame.theme.colours[self.colour]! }
    var shapeOfSymbols  : ShapeSetGame.Shape { ShapeSetGame.theme.shapes[self.shape]! }
    var fillOfSymbols   : ShapeSetGame.Fill { ShapeSetGame.theme.fills[self.fill]! }
}

class ShapeSetGame: ObservableObject {
    
    public typealias SetGameShapes = SetGame<Shapes>
    
    enum Fill { case none, solid, hatched }
    enum Shape { case capsule, diamond, sqiggle }
    
    static let theme =
        Theme(name: "Traditional",
              colours: [.one: .red,     .two: .green,   .three: .purple],
              shapes:  [.one: .capsule, .two: .diamond, .three: .sqiggle],
              fills:   [.one: .none,    .two: .solid,   .three: .hatched],
              number:  [.one: 1,        .two: 2,        .three: 3])
    
    @Published private var game = createSetGame()
    
    var cards : [SetGameShapes.Card] { game.cards }
    
    static private func createSetGame() -> SetGameShapes {
        SetGameShapes { colour, shape, fill, number in
            Shapes(colour: colour, shape: shape, fill: fill, number: number)
        }
    }
    
    private static let capsule = RoundedRectangle(cornerRadius: Tweaks.radius)
    
    @ViewBuilder static func strokedSymbol(shape: Shape, colour: Color) -> some View {
        switch shape {
        case .capsule: capsule.strokeBorder(colour, lineWidth: Tweaks.lineWidth).padding().aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .sqiggle: Squiggle().stroke(colour, lineWidth: Tweaks.lineWidth).padding().aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .diamond: Diamond().stroke(colour, lineWidth: Tweaks.lineWidth).padding().aspectRatio(Tweaks.aspect, contentMode: .fit)
        }
    }
    
    @ViewBuilder static func filledSymbol(shape: Shape, colour: Color) -> some View {
        switch shape {
        case .capsule: capsule.fill(colour).padding().aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .sqiggle: Squiggle().fill(colour).padding().aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .diamond: Diamond().fill(colour).padding().aspectRatio(Tweaks.aspect, contentMode: .fit)
        }
    }
    
    @ViewBuilder static func hatchedSymbol(shape: Shape, colour: Color) -> some View {
        switch shape {
        case .capsule: capsule.stripes(colour: colour).padding().aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .sqiggle: Squiggle().stripes(colour: colour).padding().aspectRatio(Tweaks.aspect, contentMode: .fit)
        case .diamond: Diamond().stripes(colour: colour).padding().aspectRatio(Tweaks.aspect, contentMode: .fit)
        }
    }
    
    struct Theme {
        let name: String
        let colours: [Triple:Color]
        let shapes:  [Triple:Shape]
        let fills:   [Triple:Fill]
        let number:  [Triple:Int]
    }
    
    // MARK: - Tweaking constants
    struct Tweaks {
        static let lineWidth = CGFloat(3)
        static let radius = CGFloat(150)
        static let aspect = CGFloat(3.0/2.0)
    }
    
    
    // MARK: - Intents
    
    func choose(_ card: SetGameShapes.Card) { game.choose(card) }
    
    func deal3() {
        
    }
    
    func newGame() {
        game = ShapeSetGame.createSetGame()
    }
}

