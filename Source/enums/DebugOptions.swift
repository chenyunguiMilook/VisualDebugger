//
//  DebugOptions.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation

public struct DebugOptions: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let flipped    = DebugOptions(rawValue: 1 << 0)
    public static let big        = DebugOptions(rawValue: 1 << 1)
    public static let gradient   = DebugOptions(rawValue: 1 << 2)
    public static let showLabels = DebugOptions(rawValue: 1 << 3)
    public static let showOrigin = DebugOptions(rawValue: 1 << 4)
}
