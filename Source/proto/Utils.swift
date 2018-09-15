//
//  Utils.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import CoreGraphics
import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#else
import Cocoa
#endif

public func debugLayer(_ layer: CALayer, withMargin margin: CGFloat) -> AppView {
    layer.frame.origin.x += margin
    layer.frame.origin.y += margin

    let width = layer.bounds.width + margin * 2
    let height = layer.bounds.height + margin * 2
    let frame = CGRect(x: 0, y: 0, width: width, height: height)
    #if os(iOS) || os(tvOS)
    let view = AppView(frame: frame)
        view.backgroundColor = UIColor.white
    #elseif os(macOS)
    let view = FlippedView(frame: frame)
    #endif
    view.addSublayer(layer)
    return view
}

func getDivision(_ value: Double, segments: Int = 5) -> Float {
    let logValue = log10(value)
    let exp = logValue < 0 ? -floor(abs(logValue)) : floor(logValue)
    var bigger = pow(10, exp)
    bigger = bigger < value ? pow(10, exp + 1) : bigger

    let step = 0.25
    for presision in [1, 2] {
        for i in stride(from: step, to: 0.05, by: -0.05) {
            for j in stride(from: i, through: 1.0, by: i) {
                let length = bigger * j
                if value == length {
                    return Float(length) / Float(segments)
                } else if value < length {
                    let division = length / Double(segments)
                    if division * Double(segments - presision) < value {
                        return Float(division)
                    }
                }
            }
        }
    }
    return Float(bigger) / Float(segments)
}

func calculatePrecision(_ value: Double) -> Int {
    let exp = log10(value)
    if exp < 0 {
        return Int(ceil(abs(exp))) + 1
    }
    return 1
}

func clockwiseInYDown(v0: CGPoint, v1: CGPoint, v2: CGPoint) -> Bool {
    return (v2.x - v0.x) * (v1.y - v2.y) < (v2.y - v0.y) * (v1.x - v2.x)
}

