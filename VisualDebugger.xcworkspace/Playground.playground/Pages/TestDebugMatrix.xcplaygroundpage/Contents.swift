//: [Previous](@previous)

import Foundation
import CoreGraphics
import VisualDebugger
import UIKit

public func * (lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform {
    return lhs.concatenating(rhs)
}

let scale = CGAffineTransform(scaleX: 1.2, y: 1.4)
let rotate = CGAffineTransform(rotationAngle: CGFloat.pi/4)
let translate = CGAffineTransform(translationX: 10, y: 10)
let transform = scale * rotate * translate

let affineRect = CGRect(origin: .zero, size: CGSize(width: 100, height: 100)).affineRect

transform.getAffineTransform(rect: affineRect).debugView


