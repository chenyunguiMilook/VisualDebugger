//
//  Axis.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import Foundation

public struct Axis {
    public static let markLength: Double = 6
    public static let precision: Int = 6

    public enum Kind {
        case x(origin: CGPoint) // x axis with origin
        case y(origin: CGPoint) // y axis with origin
    }
    public struct Mark {
        public enum Kind {
            case x, y
        }
        public var type: Kind
        public var value: Double
        public var position: CGPoint
        
        public init(type: Kind, value: Double, position: CGPoint) {
            self.type = type
            self.value = value
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
            self.start = Mark(type: .x, value: start - side, position: .init(x: start - side, y: y))
            self.origin = Mark(type: .x, value: center.x, position: center)
            self.end = Mark(type: .x, value: end + side, position: .init(x: end + side, y: y))
            self.marks = marks.map {  Mark(type: .x, value: $0, position: .init(x: $0, y: y)) }
        case .y(let center):
            let x = center.x
            self.start = Mark(type: .y, value: start - side, position: .init(x: x, y: start - side))
            self.origin = Mark(type: .y, value: center.y, position: center)
            self.end = Mark(type: .y, value: end + side, position: .init(x: x, y: end + side))
            self.marks = marks.map {  Mark(type: .y, value: $0, position: .init(x: x, y: $0)) }
        }
    }
    
    package init(type: Kind, start: Mark, origin: Mark, end: Mark, marks: [Mark]) {
        self.type = type
        self.start = start
        self.origin = origin
        self.end = end
        self.marks = marks
    }
    
    public func renderElements(coordinateSystem: CoordinateSystem2D) -> [any Debuggable] {
        let marks: [any Debuggable] = self.marks.compactMap { mark in
            if mark.value == origin.value { return nil }
            return mark.mark(size: Self.markLength)
        }
        let labels: [any Debuggable] = self.marks.compactMap{ mark in
            if mark.value == origin.value { return nil }
            return mark.label(precision: Self.precision)
        }
        return [axis(), arrow(size: Self.markLength, coordinateSystem: coordinateSystem)] + marks + labels
    }
}

extension Axis {
    
    public func estimateMaxLabelWidth(with style: TextRenderStyle) -> CGFloat? {
        self.marks.compactMap {
            $0.label(precision: Self.precision).bounds?.width
        }.max()
    }
    
    public func axis() -> ShapeRenderElement {
        let path = AppBezierPath()
        path.move(to: start.position)
        path.addLine(to: end.position)
        return ShapeRenderElement(path: path, style: .axis)
    }
    
    public func arrow(size: Double, coordinateSystem: CoordinateSystem2D) -> MarkRenderElement<ShapeElement> {
        switch self.type {
        case .x:
            let e = ShapeElement(path: AppBezierPath.xArrow(size: size), style: .arrow)
            return MarkRenderElement(content: e, position: end.position)
        case .y:
            switch coordinateSystem {
            case .yUp:
                let e = ShapeElement(path: AppBezierPath.yUpArrow(size: size), style: .arrow)
                return MarkRenderElement(content: e, position: end.position)
            case .yDown:
                let e = ShapeElement(path: AppBezierPath.yDownArrow(size: size), style: .arrow)
                return MarkRenderElement(content: e, position: end.position)
            }
        }
    }
}

extension Axis.Mark {
    public func mark(size: Double) -> MarkRenderElement<ShapeElement> {
        switch type {
        case .x:
            let e = ShapeElement(path: AppBezierPath.xMark(size: size), style: .axis)
            return MarkRenderElement(content: e, position: position)
        case .y:
            let e = ShapeElement(path: AppBezierPath.yMark(size: size), style: .axis)
            return MarkRenderElement(content: e, position: position)
        }
    }
    
    public func label(precision: Int) -> NumberRenderElement {
        switch type {
        case .x:
            NumberRenderElement(value: value, precision: precision, style: .xAxisLabel, position: position)
        case .y:
            NumberRenderElement(value: value, precision: precision, style: .yAxisLabel, position: position)
        }
    }
}
