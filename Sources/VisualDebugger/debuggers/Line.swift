//
//  Line.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/5.
//

//
//  Line.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/5.
//

import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public typealias VLine = Line

public final class Line: SegmentDebugger {
    
    public let start: CGPoint
    public let end: CGPoint
    
    var center: CGPoint { (start + end) / 2.0 }
    
    public lazy var vertices: [Vertex] = getVertices(from: [start, end])
    public lazy var edge: Edge = {
        createEdge(start: start, end: end, edgeIndex: 0, startIndex: 0, endIndex: 1)
    }()
    
    public init(
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
        self.start = start
        self.end = end
        super.init(
            name: name,
            transform: transform,
            color: color,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            labelStyle: labelStyle, 
            useColorfulLable: useColorfulLabel
        )
    }
}

extension Line: Transformable {
    public func applying(transform: Matrix2D) -> Line {
        Line(
            start: self.start,
            end: self.end,
            transform: self.transform * transform,
            color: self.color,
            vertexShape: self.vertexShape,
            edgeShape: self.edgeShape,
            useColorfulLabel: useColorfulLabel
        )
    }
}

extension Line: DebugRenderable {
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

extension Line {
    // 设置边样式
    @discardableResult
    public func setEdgeStyle(
        shape: EdgeShape? = nil,
        style: PathStyle? = nil,
        label: LabelStyle? = nil,
        offset: Double? = nil
    ) -> Line {
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
    ) -> Line {
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
    ) -> Line {
        let style = VertexStyle(shape: shape, style: style, label: label)
        self.vertexStyleDict[1] = style
        return self
    }
    
    public func setStartStyle(_ style: VertexStyle) -> Line {
        self.vertexStyleDict[0] = style
        return self
    }

    public func setEndStyle(_ style: VertexStyle) -> Line {
        self.vertexStyleDict[1] = style
        return self
    }
    
    public func useColorfulLabel(_ value: Bool) -> Line {
        self.useColorfulLabel = value
        return self
    }

    // 显示选项
    public func show(_ option: DisplayOptions) -> Self {
        self.displayOptions = option
        return self
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    DebugView {
        Line(
            start: .init(x: 50, y: 50),
            end: .init(x: 250, y: 150),
            edgeShape: .line
        )
        .setStartStyle(label: "Start")
        .setEndStyle(shape: .index, style: .init(color: .red), label: "End")
        
        Line(
            start: .init(x: 50, y: 200),
            end: .init(x: 250, y: 180),
            color: .green,
            edgeShape: .arrow(Arrow(direction: .double))
        )
        .setEdgeStyle(style: .init(color: .red, mode: .fill), label: .string("edge", at: .center))
    }
    .coordinateVisible(true)
    .coordinateStyle(.default)
    .coordinateSystem(.yDown)
}
