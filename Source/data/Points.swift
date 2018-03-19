//
//  Points.swift
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

public struct Points {
    
    public enum Representation {
        case dot
        case path
        case orderedPath
        case polygon
        case indices
    }

    public var representation: Representation
    public var points: [CGPoint]
}




// MARK: - PointsLabelRepresenter

public struct PointsLabelRepresenter {
    public var points: [CGPoint]
}

extension PointsLabelRepresenter : Debuggable {
    
    public var bounds: CGRect {
        return self.points.bounds
    }
    
    public func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor) {
        let pnts = self.points * transform
        for (i, point) in pnts.enumerated() {
            let textLayer = CATextLayer(indexLabel: "\(i)", color: color)
            textLayer.setCenter(point)
            textLayer.applyDefaultContentScale()
            layer.addSublayer(textLayer)
        }
    }
}

// MARK: - PointsGradientRepresenter

public struct PointsGradientRepresenter {
    public var points: [CGPoint]
}

extension PointsGradientRepresenter : Debuggable {
    
    public var bounds: CGRect {
        return self.points.bounds
    }
    
    public func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor) {
        let pnts = self.points * transform
        for (i, center) in pnts.enumerated() {
            let path: AppBezierPath
            if i == 0 || i == points.count-1 {
                let rect = CGRect(x: center.x-kPointRadius/2, y: center.y-kPointRadius/2, width: kPointRadius, height: kPointRadius)
                path = AppBezierPath(rect: rect)
            } else {
                path = center.getBezierPath(radius: kPointRadius)
            }
            let ratio = CGFloat(i)/CGFloat(points.count)
            let toColor = AppColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            let color = interpolate(from: .red, to: toColor, ratio: ratio)
            let shape = CAShapeLayer(path: path.cgPath, strokeColor: nil, fillColor: color, lineWidth: 0)
            layer.addSublayer(shape)
        }
    }
}

// MARK: - Point

extension CGPoint : Debuggable {
    
    public var bounds: CGRect {
        return CGRect(origin: self, size: .zero)
    }
    
    public func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor) {
        let newPoint = self * transform
        let path = newPoint.getBezierPath(radius: kPointRadius)
        let shapeLayer = CAShapeLayer(path: path.cgPath, strokeColor: nil, fillColor: color, lineWidth: 0)
        layer.addSublayer(shapeLayer)
    }
}





















