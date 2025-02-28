//
//  DebugPoints.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class DebugPoints {
        
    public enum EdgeStyle { // for each pair of vertics
        case line(color: AppColor)
        case dashed(color: AppColor)
    }
    
    public let points: [CGPoint]
    
    // additional style
    public var pointStyle: PointStyle
    public var pointStyleDict: [Int: PointStyle] = [:]
    
    // TOOD: support init from primitives, like polygon, triangle
    
    public init(
        points: [CGPoint],
        pointStyle: PointStyle = .shape(shape: .circle, color: .yellow),
        pointStyleDict: [Int: PointStyle] = [:]
    ) {
        self.points = points
        self.pointStyle = pointStyle
        self.pointStyleDict = pointStyleDict
    }
    
    public func overridePointStyle(at index: Int, style: PointStyle) -> DebugPoints {
        pointStyleDict[index] = style
        return self
    }
}

extension DebugPoints: Debuggable {
    public var debugBounds: CGRect? {
        return points.bounds
    }
    
    public func applying(transform: Matrix2D) -> DebugPoints {
        DebugPoints(points: points * transform, pointStyle: pointStyle, pointStyleDict: pointStyleDict)
    }
    
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        for (i, point) in points.enumerated() {
            let style = pointStyleDict[i] ?? pointStyle
            let element = style.getRenderElement(center: point)
            element.render(in: context, scale: scale, contextHeight: contextHeight)
        }
    }
}
