//
//  WeightPoint.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/5/11.
//

import Foundation
import CoreGraphics
#if os(iOS) || os(tvOS)
import UIKit
#else
import Cocoa
#endif

public struct WeightPoint {
    
    public var x: CGFloat
    public var y: CGFloat
    public var weight: CGFloat
}

extension WeightPoint : Debuggable {
    
    public var bounds: CGRect {
        return CGRect.init(x: x, y: y, width: 0, height: 0)
    }
    
    public func debug(in coordinate: CoordinateSystem, color: AppColor?) {
        let newPoint = CGPoint(x: x, y: y) * coordinate.matrix
        let path = newPoint.getBezierPath(radius: kPointRadius)
        var color = color ?? coordinate.getNextColor()
            color = color.withAlphaComponent(self.weight)
        let shapeLayer = CAShapeLayer(path: path.cgPath, strokeColor: nil, fillColor: color, lineWidth: 0)
        coordinate.addSublayer(shapeLayer)
    }
}
