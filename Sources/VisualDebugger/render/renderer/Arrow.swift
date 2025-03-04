//
//  ArrowRenderer.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/4.
//

import CoreGraphics

extension Arrow {
    public enum Style {
        case line // current implementation
        case triangle // draw a triangle and an line
        case topTriangle // top part of the triangle
        case bottomTriangle // bottom part of the triangle
    }
    
    public enum Direction {
        case normal
        case reverse
        case double // double headed
    }
}

public struct Arrow {
    public let style: Style
    public let direction: Direction
    public let tip: Tip

    public init(
        style: Style = .triangle,
        direction: Direction = .normal,
        tip: Tip = Tip()
    ) {
        self.style = style
        self.direction = direction
        self.tip = tip
    }
}

extension Arrow {
    
    public func getBezierPath(start: CGPoint, end: CGPoint) -> AppBezierPath {
        let angle = (end - start).angle
        let startTransform = Matrix2D(rotationAngle: angle + .pi) * Matrix2D(translation: start)
        let endTransform = Matrix2D(rotationAngle: angle) * Matrix2D(translation: end)
        let startTip = tip * startTransform
        let endTip = tip * endTransform
        
        let path = AppBezierPath()
        if direction == .normal || direction == .double { // has end
            let tip = endTip
            switch style {
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
            switch style {
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

extension Arrow {
    public struct Tip {
        public var tip: CGPoint
        public var topLeft: CGPoint
        public var bottomLeft: CGPoint
        
        public var middleLeft: CGPoint {
            (topLeft + bottomLeft) / 2.0
        }
        
        public var length: Double {
            (middleLeft - tip).length
        }
        
        public init(angle: Double = .pi / 8, length: Double = 8) {
            let width = length
            let height = 2 * length * sin(angle)
            self.init(width: width, height: height)
        }
        
        public init(width: Double, height: Double) {
            self.tip = .zero
            self.topLeft = .init(x: -width, y: -height/2)
            self.bottomLeft = .init(x: -width, y: height/2)
        }
        
        public init(tip: CGPoint, topLeft: CGPoint, bottomLeft: CGPoint) {
            self.tip = tip
            self.topLeft = topLeft
            self.bottomLeft = bottomLeft
        }
    }
}

func *(lhs: Arrow.Tip, rhs: Matrix2D) -> Arrow.Tip {
    Arrow.Tip(
        tip: lhs.tip * rhs,
        topLeft: lhs.topLeft * rhs,
        bottomLeft: lhs.bottomLeft * rhs
    )
}
