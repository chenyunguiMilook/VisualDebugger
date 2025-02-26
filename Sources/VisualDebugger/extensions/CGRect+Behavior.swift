//
//  CGRect.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


import CoreGraphics

extension CGRect {
    
    // MARK: - top
    public init(topLeft point: CGPoint, size: CGSize) {
        self.init(origin: point, size: size)
    }
    
    public init(topCenter point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x - size.width / 2, y: point.y)
        self.init(origin: origin, size: size)
    }
    
    public init(topRight point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x - size.width, y: point.y)
        self.init(origin: origin, size: size)
    }
    
    // MARK: - middle
    public init(middleLeft point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x, y: point.y - size.height / 2)
        self.init(origin: origin, size: size)
    }
    
    public init(center point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2)
        self.init(origin: origin, size: size)
    }
    
    public init(middleRight point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x - size.width, y: point.y - size.height / 2)
        self.init(origin: origin, size: size)
    }
    
    // MARK: - right
    public init(bottomLeft point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x, y: point.y - size.height)
        self.init(origin: origin, size: size)
    }
    
    public init(bottomCenter point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x - size.width / 2, y: point.y - size.height)
        self.init(origin: origin, size: size)
    }
    
    public init(bottomRight point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x - size.width, y: point.y - size.height)
        self.init(origin: origin, size: size)
    }
    
    public init(anchor: Anchor, center: CGPoint, size: CGSize) {
        switch anchor {
        case .topLeft: self = CGRect(topLeft: center, size: size)
        case .topCenter: self = CGRect(topCenter: center, size: size)
        case .topRight: self = CGRect(topRight: center, size: size)
        case .midLeft: self = CGRect(middleLeft: center, size: size)
        case .midCenter: self = CGRect(center: center, size: size)
        case .midRight: self = CGRect(middleRight: center, size: size)
        case .btmLeft: self = CGRect(bottomLeft: center, size: size)
        case .btmCenter: self = CGRect(bottomCenter: center, size: size)
        case .btmRight: self = CGRect(bottomRight: center, size: size)
        }
    }
    
    public func expanding(by insets: AppEdgeInsets) -> CGRect {

        let x = self.origin.x - insets.left
        let y = self.origin.y - insets.top
        let w = self.size.width + (insets.left + insets.right)
        let h = self.size.height + (insets.top + insets.bottom)
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    public func shrinked(_ value: CGFloat) -> CGRect {
        return self.insetBy(dx: value, dy: value)
    }
}

extension CGRect {
    public var topLeft: CGPoint {
        return CGPoint(x: self.minX, y: self.minY)
    }

    public var topCenter: CGPoint {
        return CGPoint(x: self.midX, y: self.minY)
    }

    public var topRight: CGPoint {
        return CGPoint(x: self.maxX, y: self.minY)
    }

    public var middleLeft: CGPoint {
        return CGPoint(x: self.minX, y: self.midY)
    }

    public var middleRight: CGPoint {
        return CGPoint(x: self.maxX, y: self.midY)
    }

    public var bottomLeft: CGPoint {
        return CGPoint(x: self.minX, y: self.maxY)
    }

    public var bottomCenter: CGPoint {
        return CGPoint(x: self.midX, y: self.maxY)
    }

    public var bottomRight: CGPoint {
        return CGPoint(x: self.maxX, y: self.maxY)
    }

    public var center: CGPoint {
        return CGPoint(
            x: self.origin.x + self.size.width / 2,
            y: self.origin.y + self.size.height / 2
        )
    }

    public func getAnchor(_ anchor: Anchor) -> CGPoint {
        switch anchor {
        case .topLeft: return self.topLeft
        case .topCenter: return self.topCenter
        case .topRight: return self.topRight

        case .midLeft: return self.middleLeft
        case .midCenter: return self.center
        case .midRight: return self.middleRight

        case .btmLeft: return self.bottomLeft
        case .btmCenter: return self.bottomCenter
        case .btmRight: return self.bottomRight
        }
    }
}

extension CGRect {
    public var rectFromOrigin: CGRect {
        let minX = min(0, self.minX)
        let minY = min(0, self.minY)
        let maxX = max(0, self.maxX)
        let maxY = max(0, self.maxY)
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

extension Array where Element == CGRect {

    public var bounds: CGRect? {
        guard !self.isEmpty else { return nil }
        var rect = self[0]
        for i in 1..<self.count {
            rect = self[i].union(rect)
        }
        return rect
    }
}

