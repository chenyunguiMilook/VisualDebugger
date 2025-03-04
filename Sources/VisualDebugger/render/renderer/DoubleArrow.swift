//
//  DoubleArrow.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/4.
//

public struct DoubleArrow {
    public enum Direction {
        case normal
        case reverse
    }
    
    public let direction: Direction
    public let tip: Arrow.Tip
    
    public init(direction: Direction, tip: Arrow.Tip) {
        self.direction = direction
        self.tip = tip
    }
}
