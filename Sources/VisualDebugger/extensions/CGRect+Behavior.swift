//
//  CGRect+Behavior.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics
#if os(iOS) || os(tvOS)
    import UIKit
#else
    import Cocoa
#endif

extension CGRect {
    
    public static let unit: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    
    public var affineRect: AffineRect {
        return AffineRect(x: origin.x, y: origin.y, width: width, height: height)
    }
    
    internal func fixed() -> CGRect {
        guard self.width == 0 || self.height == 0 else { return self }
        let width = self.width == 0 ? min(self.height / 2, 1) : self.width
        let height = self.height == 0 ? min(self.width / 2, 1) : self.height
        return CGRect(origin: self.origin, size: CGSize(width: width, height: height))
    }
    
    public var rectFromOrigin: CGRect {
        let minX = min(0, self.minX)
        let minY = min(0, self.minY)
        let maxX = max(0, self.maxX)
        let maxY = max(0, self.maxY)
        return CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
    }
}

extension CGRect : Debuggable {
    public var bounds: CGRect {
        return self
    }
    
    public func debug(in coordinate: CoordinateSystem, color: AppColor?) {
        let rect = self.applying(coordinate.matrix)
        let color = color ?? coordinate.getNextColor()
        let path = AppBezierPath.init(rect: rect)
        let shape = CAShapeLayer.init(path: path.cgPath,
                                      strokeColor: color, fillColor: nil, lineWidth: 1)
        coordinate.addSublayer(shape)
    }
}

extension Array where Element == CGRect {
    
    public var bounds: CGRect {
        guard !self.isEmpty else { return .zero }
        var rect = self[0]
        for i in 1 ..< self.count {
            rect = self[i].union(rect)
        }
        return rect
    }
}
