//
//  Axis.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import Foundation

public struct Axis {
    public enum Kind {
        case x(origin: CGPoint) // x axis with origin
        case y(origin: CGPoint) // y axis with origin
    }
    public struct Mark {
        public enum Kind {
            case x, y
        }
        public var type: Kind
        public var position: CGPoint
        
        public var value: Double {
            switch self.type {
            case .x: position.x
            case .y: position.y
            }
        }
        
        public init(type: Kind, position: CGPoint) {
            self.type = type
            self.position = position
        }
    }
    
    public var type: Kind
    public var start: Mark
    public var origin: Mark
    public var end: Mark
    public var marks: [Mark]
    
    public init(type: Kind, start: Double, end: Double, marks: [Double], side: Double) {
        self.type = type
        switch type {
        case .x(let center):
            let y = center.y
            self.start = Mark(type: .x, position: .init(x: start - side, y: y))
            self.origin = Mark(type: .x, position: center)
            self.end = Mark(type: .x, position: .init(x: end + side, y: y))
            self.marks = marks.map {  Mark(type: .x, position: .init(x: $0, y: y)) }
        case .y(let center):
            let x = center.x
            self.start = Mark(type: .y, position: .init(x: x, y: start - side))
            self.origin = Mark(type: .y, position: center)
            self.end = Mark(type: .y, position: .init(x: x, y: end + side))
            self.marks = marks.map {  Mark(type: .y, position: .init(x: x, y: $0)) }
        }
    }
    
    public var estimateMaxLabelWidth: CGFloat? {
        self.marks.compactMap { $0.estimateSize().width }.max()
    }
}
