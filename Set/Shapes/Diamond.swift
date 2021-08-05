//
//  Diamond.swift
//  Mike's Set
//
//  Created by Mike Griebling on 2020-09-23.
//

import SwiftUI

struct Diamond : Shape {
    
    func path(in rect: CGRect) -> Path {
        let start = CGPoint(x: rect.midX, y: rect.minY)
        let right = CGPoint(x: rect.maxX, y: rect.midY)
        let bottom = CGPoint(x: rect.midX, y: rect.maxY)
        let left = CGPoint(x: rect.minX, y: rect.midY)
        var p = Path()
        p.move(to: start)
        p.addLine(to: right)
        p.addLine(to: bottom)
        p.addLine(to: left)
        p.addLine(to: start)
        return p
    }
   
}
