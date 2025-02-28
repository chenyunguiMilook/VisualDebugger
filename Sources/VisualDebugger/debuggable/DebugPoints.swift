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
    public enum VertexStyle {
        case shape(PointStyle.Shape)
        case label(String)
        case index
    }
    public enum EdgeStyle { // for each pair of vertics
        case line(color: AppColor)
        case dashed(color: AppColor)
    }
    
    public let points: [CGPoint]
    
    // additional style
    public private(set) var pointStyle: PointStyle!
    public private(set) var pointStyleDict: [Int: PointStyle] = [:]
    
    // TOOD: support init from primitives, like polygon, triangle
    
    public init(
        points: [CGPoint],
        vertexStyle: VertexStyle = .shape(.circle),
        color: AppColor = .yellow,
        radius: Double = .radius,
        filled: Bool = .filled
    ) {
        self.points = points
        switch vertexStyle {
        case .shape(let shape):
            self.pointStyle = .shape(shape: shape, color: color, radius: radius, filled: filled)
        case .index:
            for i in 0 ..< points.count {
                self.pointStyleDict[i] = .label("\(i)", color: color, filled: filled)
            }
        case .label(let string):
            self.pointStyle = .label(string, color: color, filled: filled)
        }
    }
    
    public init(
        points: [CGPoint],
        pointStyle: PointStyle,
        pointStyleDict: [Int: PointStyle]
    ) {
        self.points = points
        self.pointStyle = pointStyle
        self.pointStyleDict = pointStyleDict
    }
    
    public func overrideVertexStyle(
        at index: Int,
        style: VertexStyle,
        color: AppColor? = nil,
        radius: Double = .radius,
        filled: Bool = true
    ) -> DebugPoints {
        let pointStyle: PointStyle = switch style {
        case .shape(let shape):
            .shape(shape: shape, color: color ?? pointStyle.color, radius: radius, filled: filled)
        case .label(let string):
            .label(string, color: color ?? pointStyle.color, filled: filled)
        case .index:
            .label("\(index)", color: color ?? pointStyle.color, filled: filled)
        }
        pointStyleDict[index] = pointStyle
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
            let style = pointStyleDict[i] ?? pointStyle!
            let element = style.getRenderElement(center: point)
            element.render(in: context, scale: scale, contextHeight: contextHeight)
        }
    }
}
