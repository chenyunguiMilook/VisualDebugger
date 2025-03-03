//
//  Rotateable.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import CoreGraphics

public protocol Cloneable {
    func clone() -> Self
}

public protocol StaticRendable: Cloneable {
    var contentBounds: CGRect { get }
    
    func render(
        to location: CGPoint,
        angle: Double,
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int?
    )
}

//extension Array: StaticRendable where Element: StaticRendable {
//    public var contentBounds: CGRect {
//        return self.map{ $0.contentBounds }.bounds!
//    }
//    
//    public func render(to location: CGPoint, angle: Double, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
//        for element in self {
//            element.render(to: location, angle: angle, in: context, scale: scale, contextHeight: contextHeight)
//        }
//    }
//}
