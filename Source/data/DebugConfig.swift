//
//  DebugConfig.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics

public struct DebugConfig {
    
    public var coordinate: CoordinateSystem.Mode = .yDown
    public var scale: CGFloat = 1.5
    public var numDivisions: Int = 5
    public var showOrigin: Bool = false
    public var indexOrderRepresentation: IndexOrderRepresentation
    
    public init(coordinate: CoordinateSystem.Mode = .yDown,
                scale: CGFloat = 1.5,
                numDivisions: Int = 5,
                showOrigin: Bool = false,
                indexOrderRepresentation: IndexOrderRepresentation = .none) {
        
        self.coordinate               = coordinate
        self.scale                    = scale
        self.numDivisions             = numDivisions
        self.showOrigin               = showOrigin
        self.indexOrderRepresentation = indexOrderRepresentation
    }
    
    public init(options: DebugOptions) {
        self.coordinate = options.contains(.flipped) ? .yUp : .yDown
        self.scale = options.contains(.big) ? 3 : 1.5
        self.numDivisions = 5
        self.showOrigin = options.contains(.showOrigin)
        self.indexOrderRepresentation = .none
        if options.contains(.showLabels) { self.indexOrderRepresentation = .indexLabel }
        if options.contains(.gradient) { self.indexOrderRepresentation = .gradient }
    }
}
