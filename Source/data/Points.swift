//
//  Points.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics

public struct Points {
    
    public enum Representation {
        case dot
        case path
        case orderedPath
        case polygon
        case indices
    }

    public var representation: Representation
    public var points: [CGPoint]
}


























