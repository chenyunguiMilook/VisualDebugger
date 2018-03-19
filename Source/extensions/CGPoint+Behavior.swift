//
//  CGPoint+Behavior.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics

extension CGPoint {
    
    func getBezierPath(radius: CGFloat) -> AppBezierPath {
        let x = (self.x - radius/2.0)
        let y = (self.y - radius/2.0)
        let rect = CGRect(x: x, y: y, width: radius, height: radius)
        return AppBezierPath(ovalIn: rect)
    }
    
    var length:CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }
    
    func normalized(to length:CGFloat = 1) -> CGPoint {
        let len = length/self.length
        return CGPoint(x: self.x * len, y: self.y * len)
    }
}

func +(p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPoint(x: p1.x + p2.x, y: p1.y + p2.y)
}

func -(p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
}

func calculateAngle(_ point1:CGPoint, _ point2:CGPoint) -> CGFloat {
    return atan2(point2.y - point1.y, point2.x - point1.x)
}

func calculateDistance(_ point1:CGPoint, _ point2:CGPoint) -> CGFloat {
    let x = point2.x - point1.x
    let y = point2.y - point1.y
    return sqrt(x*x + y*y)
}

func calculateCenter(_ point1:CGPoint, _ point2:CGPoint) -> CGPoint {
    return CGPoint(x: point1.x+(point2.x-point1.x)/2.0, y: point1.y+(point2.y-point1.y)/2.0)
}

extension Array where Element == CGPoint {
    
    var bounds:CGRect {
        guard let pnt = self.first else { return CGRect.zero }
        var (minX, maxX, minY, maxY) = (pnt.x, pnt.x, pnt.y, pnt.y)
        
        for point in self {
            minX = point.x < minX ? point.x : minX
            minY = point.y < minY ? point.y : minY
            maxX = point.x > maxX ? point.x : maxX
            maxY = point.y > maxY ? point.y : maxY
        }
        return CGRect(x: minX, y: minY, width: (maxX-minX), height: (maxY-minY))
    }
}





