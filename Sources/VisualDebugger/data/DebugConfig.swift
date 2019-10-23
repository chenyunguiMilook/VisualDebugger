//
//  DebugConfig.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics

public struct DebugConfig {
    
    public var coordinate: CoordinateSystem.Kind = .yDown
    public var scale: CGFloat = 1.5
    public var numDivisions: Int = 5
    public var showOrigin: Bool = false
    
    public init(coordinate: CoordinateSystem.Kind = .yDown,
                scale: CGFloat = 1.5,
                numDivisions: Int = 5,
                showOrigin: Bool = false) {
        
        self.coordinate               = coordinate
        self.scale                    = scale
        self.numDivisions             = numDivisions
        self.showOrigin               = showOrigin
    }
    
    public init(options: DebugOptions) {
        self.coordinate = options.contains(.flipped) ? .yUp : .yDown
        self.scale = options.contains(.big) ? 3 : 1.5
        self.numDivisions = 5
        self.showOrigin = options.contains(.showOrigin)
    }
}
