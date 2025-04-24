//
//  Ray.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/11.
//

import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import VisualUtils

public typealias VRay = Ray

public final class Ray: SegmentDebugger {
    
    public let start: CGPoint
    
    public var angle: CGFloat
    public var length: CGFloat

    public var end: CGPoint {
        CGPoint(
            x: start.x + cos(angle) * length,
            y: start.y + sin(angle) * length
        )
    }
    
    var center: CGPoint { (start + end) / 2.0 }
    
    public lazy var vertices: [Vertex] = getVertices(from: [start, end])
    public lazy var edge: MeshEdge = {
        createEdge(start: start, end: end, edgeIndex: 0, startIndex: 0, endIndex: 1)
    }()
    
    // 通过起点、角度和长度初始化
    public init(
        start: CGPoint,
        angle: Double = 0,
        length: Double = 50,
        name: String? = nil,
        transform: Matrix2D = .identity,
        color: AppColor = .yellow,
        vertexShape: VertexShape = .shape(Circle(radius: 2)),
        edgeShape: EdgeShape = .arrow(Arrow()),
        edgeStyle: EdgeStyle? = nil,
        labelStyle: TextRenderStyle = .nameLabel,
        useColorfulLabel: Bool = false
    ) {
        self.start = start
        self.angle = angle
        self.length = length
        
        super.init(
            name: name,
            transform: transform,
            color: color,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            labelStyle: labelStyle,
            useColorfulLable: useColorfulLabel
        )
        self.vertexStyleDict[1] = .init(shape: .shape(.empty()), style: nil, label: nil)
    }
    
    // 通过起点和终点初始化
    public convenience init(
        start: CGPoint,
        end: CGPoint,
        name: String? = nil,
        transform: Matrix2D = .identity,
        color: AppColor = .yellow,
        vertexShape: VertexShape = .shape(Circle(radius: 2)),
        edgeShape: EdgeShape = .arrow(Arrow()),
        edgeStyle: EdgeStyle? = nil,
        labelStyle: TextRenderStyle = .nameLabel,
        useColorfulLabel: Bool = false
    ) {
        self.init(
            start: start,
            angle: (end - start).angle,
            length: (end - start).length,
            name: name,
            transform: transform,
            color: color,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            edgeStyle: edgeStyle,
            labelStyle: labelStyle,
            useColorfulLabel: useColorfulLabel
        )
    }

    public convenience init(
        start: CGPoint,
        direction: CGPoint,
        length: Double = 10,
        name: String? = nil,
        transform: Matrix2D = .identity,
        color: AppColor = .yellow,
        vertexShape: VertexShape = .shape(Circle(radius: 2)),
        edgeShape: EdgeShape = .arrow(Arrow()),
        edgeStyle: EdgeStyle? = nil,
        labelStyle: TextRenderStyle = .nameLabel,
        useColorfulLabel: Bool = false
    ) {
        self.init(
            start: start,
            angle: direction.angle,
            length: length,
            name: name,
            transform: transform,
            color: color,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            edgeStyle: edgeStyle,
            labelStyle: labelStyle,
            useColorfulLabel: useColorfulLabel
        )
    }
}

extension Ray: DebugRenderable {
    public var debugBounds: CGRect? {
        let minX = min(start.x, end.x)
        let minY = min(start.y, end.y)
        let maxX = max(start.x, end.x)
        let maxY = max(start.y, end.y)
        let rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        return rect * transform
    }
    
    public func render(with transform: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        if displayOptions.contains(.edge) {
            edge.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
        }
        if displayOptions.contains(.vertex) {
            for vertex in self.vertices {
                vertex.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
            }
        }
    }
}

extension Ray {
    // 设置边样式
    @discardableResult
    public func setEdgeStyle(
        shape: EdgeShape? = nil,
        style: PathStyle? = nil,
        label: LabelStyle? = nil,
        offset: Double? = nil
    ) -> Ray {
        self.edgeStyleDict[0] = EdgeStyle(
            shape: shape,
            style: style,
            label: label,
            offset: offset
        )
        return self
    }
    
    // 设置起点样式
    @discardableResult
    public func setStartStyle(
        shape: VertexShape? = nil,
        style: PathStyle? = nil,
        label: LabelStyle? = nil
    ) -> Ray {
        let style = VertexStyle(shape: shape, style: style, label: label)
        self.vertexStyleDict[0] = style
        return self
    }
    
    // 设置终点样式
    @discardableResult
    public func setEndStyle(
        shape: VertexShape? = nil,
        style: PathStyle? = nil,
        label: LabelStyle? = nil
    ) -> Ray {
        let style = VertexStyle(shape: shape, style: style, label: label)
        self.vertexStyleDict[1] = style
        return self
    }
    
    public func setStartStyle(_ style: VertexStyle) -> Ray {
        self.vertexStyleDict[0] = style
        return self
    }

    public func setEndStyle(_ style: VertexStyle) -> Ray {
        self.vertexStyleDict[1] = style
        return self
    }
    
    public func useColorfulLabel(_ value: Bool) -> Ray {
        self.useColorfulLabel = value
        return self
    }
    
    public func setAngle(_ angle: Double) -> Self {
        self.angle = angle
        return self
    }

    public func setLength(_ length: Double) -> Self {
        self.length = length
        return self
    }
    
    // 显示选项
    public func show(_ option: DisplayOptions) -> Self {
        self.displayOptions = option
        return self
    }
    
    public func log(_ message: Any..., level: Logger.Log.Level = .info) -> Self {
        self.logging(message, level: level)
        return self
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    DebugView {
        // 使用两点初始化
        Ray(
            start: .init(x: 50, y: 50),
            end: .init(x: 250, y: 150)
        )
        .setLength(100)
        
        // 使用角度和长度初始化
        Ray(
            start: .init(x: 50, y: 200),
            angle: .pi / 4, // 45度
            length: 200,
            color: .green
        )
    }
    .coordinateVisible(true)
    .coordinateStyle(.default)
    .coordinateSystem(.yDown)
} 
