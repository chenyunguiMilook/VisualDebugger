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
        case shape(PointStyle.Shape, name: String? = nil)
        case label(String, name: String? = nil)
        case index(name: String? = nil)
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
        radius: Double = .pointRadius,
        filled: Bool = .filled
    ) {
        self.points = points
        switch vertexStyle {
        case .shape(let shape, _):
            self.pointStyle = .shape(shape: shape, color: color, name: nil, radius: radius, filled: filled)
        case .index:
            for i in 0 ..< points.count {
                self.pointStyleDict[i] = .label("\(i)", color: color, filled: filled)
            }
        case .label(let string, _):
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
        radius: Double = .pointRadius,
        filled: Bool = true
    ) -> DebugPoints {
        let pointStyle: PointStyle = switch style {
        case .shape(let shape, let name):
            .shape(shape: shape, color: color ?? pointStyle.color, name: name, radius: radius, filled: filled)
        case .label(let string, let name):
            .label(string, color: color ?? pointStyle.color, name: name, filled: filled)
        case .index(let name):
            .label("\(index)", color: color ?? pointStyle.color, name: name, filled: filled)
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
            for element in style.getRenderElements(center: point) {
                element.render(in: context, scale: scale, contextHeight: contextHeight)
            }
        }
    }
}
