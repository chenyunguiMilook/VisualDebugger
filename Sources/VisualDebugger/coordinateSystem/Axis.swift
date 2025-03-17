//
//  Axis.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import Foundation

struct Axis {
    enum Kind {
        case x(origin: CGPoint) // x axis with origin
        case y(origin: CGPoint) // y axis with origin
    }
    struct Mark {
        enum Kind {
            case x, y
        }
        var type: Kind
        var position: CGPoint
        
        var value: Double {
            switch self.type {
            case .x: position.x
            case .y: position.y
            }
        }
        
        init(type: Kind, position: CGPoint) {
            self.type = type
            self.position = position
        }
    }
    
    var type: Kind
    var start: Mark
    var origin: Mark
    var end: Mark
    var marks: [Mark]
    
    init(type: Kind, start: Double, end: Double, marks: [Double], side: Double) {
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
    
    var estimateMaxLabelWidth: CGFloat? {
        self.marks.compactMap { $0.estimateSize().width }.max()
    }
}
