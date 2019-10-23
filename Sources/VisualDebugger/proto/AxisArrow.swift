//
//  AxisArrow.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics

struct AxisArrow {
    
    let w1: CGFloat = 0
    let w2: CGFloat = 5
    let h: CGFloat = 3
    
    var path: AppBezierPath {
        let path = AppBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: -w1, y:  h))
        path.addLine(to: CGPoint(x:  w2, y:  0))
        path.addLine(to: CGPoint(x: -w1, y: -h))
        path.addLine(to: .zero)
        path.close()
        return path
    }
    
    func pathAtEndOfSegment(segStart p0: CGPoint, segEnd p1: CGPoint) -> AppBezierPath {
        let angle = atan2(p1.y-p0.y, p1.x-p0.x)
        var t = CGAffineTransform(rotationAngle: angle)
        t = t.concatenating(CGAffineTransform(translationX: p1.x, y: p1.y))
        let p = self.path
        p.apply(t)
        return p
    }
}
