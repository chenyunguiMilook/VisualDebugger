//
//  ArrowRenderer.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/4.
//

import CoreGraphics

extension Arrow {
    
    public enum Direction: Sendable {
        case normal
        case reverse
        case double // double headed
    }
    
    public struct Tip: Sendable {
        public enum Shape: Sendable {
            case line // current implementation
            case triangle // draw a triangle and an line
            case topTriangle // top part of the triangle
            case bottomTriangle // bottom part of the triangle
        }
        public enum Anchor: Sendable {
            case midRight
            case midLeft
        }
        public var tip: CGPoint
        public var topLeft: CGPoint
        public var bottomLeft: CGPoint
        public var shape: Shape
    }
    
    public enum Style: Sendable {
        case normal
        case offseted(offset: Double)
        case double(spacing: Double)
    }
}

public struct Arrow: Sendable {
    public let direction: Direction
    public let style: Style
    public let tip: Tip

    public init(
        direction: Direction = .normal,
        style: Style = .normal,
        tip: Tip = Tip()
    ) {
        self.direction = direction
        self.style = style
        self.tip = tip
    }
}

extension Arrow {
    public static let normal = Arrow(direction: .normal, style: .normal, tip: .init(shape: .triangle))
    public static let doubleArrow = Arrow(direction: .normal, style: .double(spacing: 4), tip: .init(shape: .bottomTriangle))
}

extension Arrow: SegmentRenderer {
    
    public func getBezierPath(start: CGPoint, end: CGPoint) -> AppBezierPath {
        switch self.style {
        case .normal:
            return getArrowPath(start: start, end: end)
        case .offseted(let offset):
            var seg = Segment(start: start, end: end)
            seg = seg.offseting(distance: offset)
            return getArrowPath(start: seg.start, end: seg.end)
        case .double(let spacing):
            let seg = Segment(start: start, end: end)
            let top = seg.offseting(distance: spacing/2)
            let btm = seg.offseting(distance: -spacing/2)
            let path = AppBezierPath()
            path.append(getArrowPath(start: top.start, end: top.end))
            path.append(getArrowPath(start: btm.end, end: btm.start))
            return path
        }
    }
    
    func getArrowPath(start: CGPoint, end: CGPoint) -> AppBezierPath {
        let angle = (end - start).angle
        let startTransform = Matrix2D(rotationAngle: angle + .pi) * Matrix2D(translation: start)
        let endTransform = Matrix2D(rotationAngle: angle) * Matrix2D(translation: end)
        let startTip = tip * startTransform
        let endTip = tip * endTransform
        
        let path = AppBezierPath()
        if direction == .normal || direction == .double { // has end
            let tip = endTip
            switch tip.shape {
            case .line:
                path.move(to: tip.topLeft)
                path.addLine(to: tip.tip)
                path.addLine(to: tip.bottomLeft)
                path.move(to: tip.tip)
            case .triangle:
                path.move(to: tip.middleLeft)
                path.addLine(to: tip.topLeft)
                path.addLine(to: tip.tip)
                path.addLine(to: tip.bottomLeft)
                path.close()
                path.move(to: tip.middleLeft)
            case .topTriangle:
                path.move(to: tip.middleLeft)
                path.addLine(to: tip.topLeft)
                path.addLine(to: tip.tip)
                path.close()
                path.move(to: tip.middleLeft)
            case .bottomTriangle:
                path.move(to: tip.middleLeft)
                path.addLine(to: tip.bottomLeft)
                path.addLine(to: tip.tip)
                path.close()
                path.move(to: tip.middleLeft)
            }
        } else {
            path.move(to: endTip.tip)
        }
        
        if direction == .reverse || direction == .double { // has start
            let tip = startTip
            switch tip.shape {
            case .line:
                path.addLine(to: tip.tip)

                path.move(to: tip.topLeft)
                path.addLine(to: tip.tip)
                path.addLine(to: tip.bottomLeft)
            case .triangle:
                path.addLine(to: tip.middleLeft)
                
                path.move(to: tip.middleLeft)
                path.addLine(to: tip.topLeft)
                path.addLine(to: tip.tip)
                path.addLine(to: tip.bottomLeft)
                path.close()

            case .topTriangle:
                path.addLine(to: tip.middleLeft)
                
                path.move(to: tip.middleLeft)
                path.addLine(to: tip.topLeft)
                path.addLine(to: tip.tip)
                path.close()
            case .bottomTriangle:
                path.addLine(to: tip.middleLeft)
                
                path.move(to: tip.middleLeft)
                path.addLine(to: tip.bottomLeft)
                path.addLine(to: tip.tip)
                path.close()
            }
        } else {
            path.addLine(to: startTip.tip)
        }
        return path
    }
}

extension Arrow.Tip {
    
    public var middleLeft: CGPoint {
        (topLeft + bottomLeft) / 2.0
    }
    
    public var length: Double {
        (middleLeft - tip).length
    }
    
    public init(angle: Double = .pi / 8, length: Double = 8, shape: Shape = .triangle, anchor: Anchor = .midRight) {
        let width = length
        let height = 2 * length * sin(angle)
        self.init(width: width, height: height, shape: shape, anchor: anchor)
    }
    
    public init(width: Double, height: Double, shape: Shape, anchor: Anchor = .midRight) {
        switch anchor {
        case .midRight:
            self.tip = .zero
            self.topLeft = .init(x: -width, y: -height/2)
            self.bottomLeft = .init(x: -width, y: height/2)
        case .midLeft:
            self.tip = .init(x: width, y: 0)
            self.topLeft = .init(x: 0, y: -height/2)
            self.bottomLeft = .init(x: 0, y: height/2)
        }
        self.shape = shape
    }
}

func *(lhs: Arrow.Tip, rhs: Matrix2D) -> Arrow.Tip {
    Arrow.Tip(
        tip: lhs.tip * rhs,
        topLeft: lhs.topLeft * rhs,
        bottomLeft: lhs.bottomLeft * rhs,
        shape: lhs.shape
    )
}
