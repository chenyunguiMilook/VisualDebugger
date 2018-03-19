//
//  Utils.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics

public func getDivision(_ value:Double, segments:Int = 5) -> Float {
    
    let logValue = log10(value)
    let exp =  logValue < 0 ? -floor(abs(logValue)) : floor(logValue)
    var bigger = pow(10, exp)
    bigger = bigger < value ? pow(10, exp+1) : bigger
    
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
