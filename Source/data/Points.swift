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

extension Array where Element == CGPoint {
    
    public var dots: Points {
        return Points.init(points: self, representation: .dots)
    }
    
    public var path: Points {
        return Points.init(points: self, representation: .path)
    }
    
    public var orderedPath: Points {
        return Points.init(points: self, representation: .orderedPath)
    }
    
    public var polygon: Points {
        return Points.init(points: self, representation: .polygon)
    }
    
    public var indices: Points {
        return Points.init(points: self, representation: .indices)
    }
}

public struct Points {
    
    public enum Representation {
        case dots
        case gradient
        case path
        case orderedPath
        case polygon
        case indices
    }

    public var representation: Representation
    public var points: [CGPoint]
    
    public init(points: [CGPoint], representation: Representation) {
        self.points = points
        self.representation = representation
    }
}

extension Points : Debuggable {
    
    public var bounds: CGRect {
        return self.points.bounds
    }
    
    public func debug(in coordinate: CoordinateSystem) {
        let points = self.points * coordinate.matrix
        self.representation.render(points: points, with: coordinate.getNextColor(), in: coordinate)
    }
}

extension Points.Representation {
    
    public func render(points: [CGPoint], with color: AppColor, in layer: CALayer) {
        
        switch self {
        case .dots:
            let path = AppBezierPath()
            for center in points {
                path.append(center.getBezierPath(radius: kPointRadius))
            }
            let shape = CAShapeLayer(path: path.cgPath, strokeColor: nil, fillColor: color, lineWidth: 0)
            layer.addSublayer(shape)
            
        case .gradient:
            for (i, center) in points.enumerated() {
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
            
        case .indices:
            for (i, point) in points.enumerated() {
                let textLayer = CATextLayer(indexLabel: "\(i)", color: color)
                textLayer.setCenter(point)
                textLayer.applyDefaultContentScale()
                layer.addSublayer(textLayer)
            }

        default: break
        }
    }
}
























