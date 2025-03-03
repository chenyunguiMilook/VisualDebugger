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

public final class Points {
    public typealias Vertex = PointRenderElement
    public typealias Edge = SegmentRenderElement<SegmentShape>
    
    public enum VertexShape {
        case shape(ShapeType)
        case index
    }
    public enum VertexDescription {
        case string(String)
        case coordinate
    }
    public enum EdgeShape {
        case line
        case arrow
    }
    public struct VertexStyle {
        let shape: VertexShape?
        let color: AppColor?
        let name: VertexDescription?
        let nameLocation: TextLocation
    }

    public let points: [CGPoint]
    public let isClosed: Bool
    public let transform: Matrix2D
    public let vertexShape: VertexShape
    public let edgeShape: EdgeShape
    public let color: AppColor
    public let vertexSize: CGSize
    public var vertexStyleDict: [Int: VertexStyle]
    
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
                    }
                }
                return createVertex(
                    index: i,
                    position: point,
                    shape: style.shape,
                    color: style.color,
                    name: nameString,
                    nameLocation: style.nameLocation,
                    transform: transform
                )
            } else {
                return createVertex(
                    index: i,
                    position: point,
                    shape: nil,
                    color: nil,
                    name: nil,
                    transform: transform
                )
            }
        }
    }()
    
    public lazy var edges: [Edge] = {
        points.segments(isClosed: isClosed).enumerated().map { (i, seg) in
            let source: SegmentShapeSource = switch edgeShape {
            case .line: .line
            case .arrow: .arrow
            }
            // TODO: need set start and end offset
            return Edge(
                start: seg.start,
                end: seg.end,
                transform: transform,
                source: source,
                style: edgeStyle(color: color)
            )
        }
    }()
    
    func vertexStyle(color: AppColor) -> ShapeRenderStyle {
        ShapeRenderStyle(
            fill: .init(color: color, style: .init())
        )
    }

    func edgeStyle(color: AppColor) -> ShapeRenderStyle {
        ShapeRenderStyle(
            stroke: .init(color: color, style: .init(lineWidth: 1)),
            fill: nil
        )
    }
    
    func labelStyle(color: AppColor) -> TextRenderStyle {
        TextRenderStyle(
            font: AppFont.italicSystemFont(ofSize: 10),
            insets: .zero,
            margin: AppEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
            anchor: .midCenter,
            textColor: AppColor.white,
            bgStyle: .capsule(color: color, filled: false)
        )
    }
    
    public init(
        _ points: [CGPoint],
        transform: Matrix2D = .identity,
        isClosed: Bool = true,
        vertexShape: VertexShape = .shape(.circle),
        edgeShape: EdgeShape = .line,
        color: AppColor = .yellow,
        vertexSize: CGSize = CGSize(width: 4, height: 4),
        vertexStyleDict: [Int: VertexStyle] = [:]
    ) {
        self.points = points
        self.isClosed = isClosed
        self.transform = transform
        self.vertexShape = vertexShape
        self.edgeShape = edgeShape
        self.color = color
        self.vertexSize = vertexSize
        self.vertexStyleDict = vertexStyleDict
    }
    
    func createVertex(
        index: Int,
        position: CGPoint,
        shape: VertexShape?,
        color: AppColor?,
        name: String?,
        nameLocation: TextLocation = .right,
        transform: Matrix2D
    ) -> Vertex {
        let shape = shape ?? self.vertexShape
        let color = color ??  self.color
        let centerShape: StaticRendable = switch shape {
        case .shape(let shape):
            ShapeElement(source: .shape(shape, size: vertexSize, anchor: .midCenter), style: vertexStyle(color: color))
        case .index:
            TextElement(source: .index(index), style: labelStyle(color: color))
        }
        var label: TextElement?
        if let name {
            label = TextElement(source: .string(name), style: .nameLabel)
        }
        let element = PointElement(shape: centerShape, label: label)
        return PointRenderElement(content: element, position: position, transform: transform)
    }
    
    public func overrideVertexStyle(
        at index: Int,
        shape: VertexShape? = nil,
        color: AppColor? = nil,
        name: VertexDescription? = nil,
        nameLocation: TextLocation = .right
    ) -> Points {
        guard index < points.count else { return self }
        let style = VertexStyle(shape: shape, color: color, name: name, nameLocation: nameLocation)
        self.vertexStyleDict[index] = style
        return self
    }
}

extension Points: Debuggable {
    public var debugBounds: CGRect? {
        points.bounds
    }
    public func applying(transform: Matrix2D) -> Points {
        Points(
            points,
            transform: self.transform * transform,
            isClosed: isClosed,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            color: color,
            vertexSize: vertexSize,
            vertexStyleDict: vertexStyleDict
        )
    }
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        for edge in edges {
            edge.render(in: context, scale: scale, contextHeight: contextHeight)
        }
        for vtx in vertices {
            vtx.render(in: context, scale: scale, contextHeight: contextHeight)
        }
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    DebugView(elements: [
        Points([
            .init(x: 40, y: 10),
            .init(x: 10, y: 23),
            .init(x: 23, y: 67)
        ], vertexShape: .index)
        .overrideVertexStyle(at: 0, shape: .shape(.rect), name: .string("Corner"))
        .overrideVertexStyle(at: 1, color: .red, name: .coordinate)
        
    ], coordinateSystem: .yDown)
}
