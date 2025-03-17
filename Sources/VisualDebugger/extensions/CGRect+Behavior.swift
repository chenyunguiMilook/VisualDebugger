//
//  CGRect.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


import CoreGraphics

extension CGRect {
    
    // MARK: - top
    init(topLeft point: CGPoint, size: CGSize) {
        self.init(origin: point, size: size)
    }
    
    init(topCenter point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x - size.width / 2, y: point.y)
        self.init(origin: origin, size: size)
    }
    
    init(topRight point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x - size.width, y: point.y)
        self.init(origin: origin, size: size)
    }
    
    // MARK: - middle
    init(middleLeft point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x, y: point.y - size.height / 2)
        self.init(origin: origin, size: size)
    }
    
    init(center point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2)
        self.init(origin: origin, size: size)
    }
    
    init(middleRight point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x - size.width, y: point.y - size.height / 2)
        self.init(origin: origin, size: size)
    }
    
    // MARK: - right
    init(bottomLeft point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x, y: point.y - size.height)
        self.init(origin: origin, size: size)
    }
    
    init(bottomCenter point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x - size.width / 2, y: point.y - size.height)
        self.init(origin: origin, size: size)
    }
    
    init(bottomRight point: CGPoint, size: CGSize) {
        let origin = CGPoint(x: point.x - size.width, y: point.y - size.height)
        self.init(origin: origin, size: size)
    }
    
    init(anchor: Anchor, center: CGPoint, size: CGSize) {
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
    
    func expanding(by insets: AppEdgeInsets) -> CGRect {

        let x = self.origin.x - insets.left
        let y = self.origin.y - insets.top
        let w = self.size.width + (insets.left + insets.right)
        let h = self.size.height + (insets.top + insets.bottom)
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    func shrinked(_ value: CGFloat) -> CGRect {
        return self.insetBy(dx: value, dy: value)
    }
    
    func fit(to rect: CGRect, config: FitConfig) -> CGAffineTransform {
        RectFitter.fit(rect: self, to: rect, config: config)
    }

    func fitted(to rect: CGRect, config: FitConfig) -> CGRect {
        let t = self.fit(to: rect, config: config)
        return self.applying(t)
    }
}

extension CGRect {
    func offseted(_ offset: CGPoint) -> CGRect {
        return CGRect(origin: self.origin + offset, size: self.size)
    }

    func offseted(x: CGFloat, y: CGFloat) -> CGRect {
        return CGRect(
            x: self.origin.x + x,
            y: self.origin.y + y,
            width: self.size.width,
            height: self.size.height
        )
    }
}

extension CGRect {
    var topLeft: CGPoint {
        return CGPoint(x: self.minX, y: self.minY)
    }

    var topCenter: CGPoint {
        return CGPoint(x: self.midX, y: self.minY)
    }

    var topRight: CGPoint {
        return CGPoint(x: self.maxX, y: self.minY)
    }

    var middleLeft: CGPoint {
        return CGPoint(x: self.minX, y: self.midY)
    }

    var middleRight: CGPoint {
        return CGPoint(x: self.maxX, y: self.midY)
    }

    var bottomLeft: CGPoint {
        return CGPoint(x: self.minX, y: self.maxY)
    }

    var bottomCenter: CGPoint {
        return CGPoint(x: self.midX, y: self.maxY)
    }

    var bottomRight: CGPoint {
        return CGPoint(x: self.maxX, y: self.maxY)
    }

    var center: CGPoint {
        return CGPoint(
            x: self.origin.x + self.size.width / 2,
            y: self.origin.y + self.size.height / 2
        )
    }

    func getAnchor(_ anchor: Anchor) -> CGPoint {
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
    var rectFromOrigin: CGRect {
        let minX = min(0, self.minX)
        let minY = min(0, self.minY)
        let maxX = max(0, self.maxX)
        let maxY = max(0, self.maxY)
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

extension Array where Element == CGRect {

    var bounds: CGRect? {
        guard !self.isEmpty else { return nil }
        var rect = self[0]
        for i in 1..<self.count {
            rect = self[i].union(rect)
        }
        return rect
    }
}

