//
//  Squiggle.swift
//  Mike's Set
//
//  Created by Michael Griebling on 9/23/20.
//

import SwiftUI

struct Squiggle: Shape {
    
    func path(in rect: CGRect) -> Path {
        let sx = 5*rect.width/568
        let sy = 5*rect.height/281
        let xoff = CGFloat(227.5)
        let yoff = CGFloat(82.5)
        
        func CGPScaled(x: CGFloat, y: CGFloat) -> CGPoint {
            return CGPoint(x: (x-xoff)*sx, y: (y-yoff)*sy)
        }
        
        var p = Path()
        p.move(to: CGPScaled(x: 233.5, y: 120.5))
        p.addCurve(to: CGPScaled(x: 247.5, y: 87.5), control1: CGPScaled(x: 233.5, y: 120.5), control2: CGPScaled(x: 227.5, y: 100.5))
        p.addCurve(to: CGPScaled(x: 275.5, y: 87.5), control1: CGPScaled(x: 253.59, y: 83.54), control2: CGPScaled(x: 270.68, y: 85.75))
        p.addCurve(to: CGPScaled(x: 292.5, y: 94.5), control1: CGPScaled(x: 286.5, y: 91.5), control2: CGPScaled(x: 287.63, y: 94.5))
        p.addCurve(to: CGPScaled(x: 309.5, y: 91.5), control1: CGPScaled(x: 296.07, y: 94.5), control2: CGPScaled(x: 302.76, y: 94.56))
        p.addCurve(to: CGPScaled(x: 325.5, y: 82.5), control1: CGPScaled(x: 315.99, y: 88.56), control2: CGPScaled(x: 322.56, y: 82.5))
        p.addCurve(to: CGPScaled(x: 334.5, y: 101.5), control1: CGPScaled(x: 331.5, y: 82.5), control2: CGPScaled(x: 337.5, y: 93.5))
        p.addCurve(to: CGPScaled(x: 308.5, y: 128.5), control1: CGPScaled(x: 331.5, y: 109.5), control2: CGPScaled(x: 330.5, y: 120.5))
        p.addCurve(to: CGPScaled(x: 295.5, y: 128.5), control1: CGPScaled(x: 303.1, y: 130.46), control2: CGPScaled(x: 300.5, y: 129.3))
        p.addCurve(to: CGPScaled(x: 280.5, y: 123.5), control1: CGPScaled(x: 292.21, y: 128.69), control2: CGPScaled(x: 280.5, y: 123.5))
        p.addCurve(to: CGPScaled(x: 251.5, y: 129.5), control1: CGPScaled(x: 280.5, y: 123.5), control2: CGPScaled(x: 265.5, y: 117.5))
        p.addCurve(to: CGPScaled(x: 237.5, y: 131.5), control1: CGPScaled(x: 246.38, y: 133.89), control2: CGPScaled(x: 239.56, y: 133.8))
        p.addCurve(to: CGPScaled(x: 233.5, y: 119.5), control1: CGPScaled(x: 233.92, y: 127.5), control2: CGPScaled(x: 233.5, y: 119.5))
        return p
    }
    
}
