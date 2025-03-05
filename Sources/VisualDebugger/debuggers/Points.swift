//
//  Points.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public typealias VPoints = Points

public final class Points: BaseDebugger {
    
    public let points: [CGPoint]
    public let isClosed: Bool
    
    public lazy var vertices: [Vertex] = {
        points.enumerated().map { (i, point) in
            if let style = vertexStyleDict[i] {
                var nameString: String?
                if let name = style.name {
                    switch name {
                    case .string(let string):
                        nameString = string
                    case .coordinate:
                        nameString = "(\(point.x), \(point.y))"
                    case .index:
                        nameString = "\(i)"
                    }
                }
                return createVertex(
                    index: i,
                    position: point,
                    shape: style.shape,
                    style: style.style,
                    name: nameString,
                    nameLocation: style.nameLocation,
                    transform: transform
                )
            } else {
                return createVertex(
                    index: i,
                    position: point,
                    shape: nil,
                    style: nil,
                    name: nil,
                    transform: transform
                )
            }
        }
    }()
    
    public lazy var edges: [Edge] = {
        points.segments(isClosed: isClosed).enumerated().map { (i, seg) in
            // 获取样式，优先使用自定义样式，否则使用默认样式
            let customStyle = edgeStyleDict[i]
            let edgeShape = customStyle?.shape ?? self.edgeShape
            
            // 根据边形状创建对应的SegmentShapeSource
            let source: SegmentRenderer? = switch edgeShape {
            case .line: nil
            case .arrow(let arrow): arrow
            }
            
            return Edge(
                start: seg.start,
                end: seg.end,
                transform: transform,
                segmentShape: source,
                segmentStyle: edgeStyle(style: customStyle?.style),
                startOffset: getRadius(index: i),
                endOffset: getRadius(index: (i+1+points.count)%points.count)
            )
        }
    }()
    
    public init(
        _ points: [CGPoint],
        transform: Matrix2D = .identity,
        isClosed: Bool = true,
        vertexShape: VertexShape = .shape(Circle(radius: 2)),
        edgeShape: EdgeShape = .arrow(Arrow()),
        color: AppColor = .yellow,
        vertexStyleDict: [Int: VertexStyle] = [:],
        edgeStyleDict: [Int: EdgeStyle] = [:],
        displayOptions: DisplayOptions = .all
    ) {
        self.points = points
        self.isClosed = isClosed
        
        super.init(
            transform: transform,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            color: color,
            vertexStyleDict: vertexStyleDict,
            edgeStyleDict: edgeStyleDict,
            displayOptions: displayOptions
        )
    }
    
    public func setVertexStyle(
        at index: Int,
        shape: VertexShape? = nil,
        style: Style? = nil,
        name: Description? = nil,
        nameLocation: TextLocation = .right
    ) -> Points {
        guard index < points.count else { return self }
        let style = VertexStyle(shape: shape, style: style, name: name, nameLocation: nameLocation)
        self.vertexStyleDict[index] = style
        return self
    }
    
    public func setEdgeStyle(
        at index: Int,
        shape: EdgeShape? = nil,
        style: Style? = nil,
        name: Description? = nil,
        nameLocation: TextLocation = .right
    ) -> Points {
        guard index < points.count - 1 || (index == points.count - 1 && isClosed) else { return self }
        let edgeStyle = EdgeStyle(
            shape: shape,
            style: style,
            name: name,
            nameLocation: nameLocation
        )
        edgeStyleDict[index] = edgeStyle
        return self
    }
    
    // MARK: - modifier
    public func display(_ option: DisplayOptions) -> Self {
        self.displayOptions = option
        return self
    }
}

extension Points: Transformable {
    public func applying(transform: Matrix2D) -> Points {
        Points(
            points,
            transform: self.transform * transform,
            isClosed: isClosed,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            color: color,
            vertexStyleDict: vertexStyleDict,
            edgeStyleDict: edgeStyleDict,
            displayOptions: displayOptions
        )
    }
}

extension Points: Debuggable {
    public var debugBounds: CGRect? {
        guard let bounds = points.bounds else { return nil }
        return bounds * transform
    }
    public func render(with transform: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        if displayOptions.contains(.edge) {
            for edge in edges {
                edge.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
            }
        }
        if displayOptions.contains(.vertex) {
            for vtx in vertices {
                vtx.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
            }
        }
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    DebugView {
        Points([
            .init(x: 40, y: 10),
            .init(x: 10, y: 23),
            .init(x: 23, y: 67)
        ], vertexShape: .index)
        .setVertexStyle(at: 0, shape: .shape(Circle(radius: 2)), name: .string("Corner"))
        .setVertexStyle(at: 1, style: .init(color: .red), name: .coordinate)
        .setEdgeStyle(at: 2, shape: .arrow(.doubleArrow), style: .init(color: .red, mode: .fill))
        .display([.vertex, .edge])
    }
    .coordinateVisible(true)
    .coordinateStyle(.default)
    .coordinateSystem(.yDown)
    //.zoom(1.5, aroundCenter: .init(x: 10, y: 23))
}
