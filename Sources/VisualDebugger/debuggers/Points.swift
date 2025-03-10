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

public final class Points: GeometryDebugger {
    
    public let points: [CGPoint]
    public let isClosed: Bool
    
    public lazy var vertices: [Vertex] = getVertices(from: points)
    
    public lazy var edges: [Edge] = {
        points.segments(isClosed: isClosed).enumerated().map { (i, seg) in
            createEdge(start: seg.start, end: seg.end, edgeIndex: i, startIndex: i, endIndex: i+1)
        }
    }()
    
    public lazy var face: MeshFace = {
        createFace(vertices: points, faceIndex: 0)
    }()
    
    public init(
        _ points: [CGPoint],
        name: String? = nil,
        transform: Matrix2D = .identity,
        isClosed: Bool = true,
        vertexShape: VertexShape = .shape(Circle(radius: 2)),
        edgeShape: EdgeShape = .arrow(Arrow()),
        color: AppColor = .yellow,
        vertexStyleDict: [Int: VertexStyle] = [:],
        edgeStyleDict: [Int: EdgeStyle] = [:],
        displayOptions: DisplayOptions = .all,
        labelStyle: TextRenderStyle = .nameLabel,
        useColorfulLabel: Bool = false
    ) {
        self.points = points
        self.isClosed = isClosed
        
        super.init(
            name: name,
            transform: transform,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            color: color,
            vertexStyleDict: vertexStyleDict,
            edgeStyleDict: edgeStyleDict,
            displayOptions: displayOptions,
            labelStyle: labelStyle,
            useColorfulLable: useColorfulLabel
        )
    }
    
    public func setVertexStyle(
        at index: Int,
        shape: VertexShape? = nil,
        style: PathStyle? = nil,
        label: LabelStyle? = nil
    ) -> Points {
        guard index < points.count else { return self }
        let style = VertexStyle(shape: shape, style: style, label: label)
        self.vertexStyleDict[index] = style
        return self
    }
    
    public func setVertexStyle(
        _ style: VertexStyle,
        for indices: Set<Int>
    ) -> Points {
        for index in indices where index < points.count {
            self.vertexStyleDict[index] = style
        }
        return self
    }
    
    public func setEdgeStyle(
        at index: Int,
        shape: EdgeShape? = nil,
        style: PathStyle? = nil,
        label: LabelStyle? = nil,
        offset: Double? = nil
    ) -> Points {
        guard index < points.count - 1 || (index == points.count - 1 && isClosed) else { return self }
        let edgeStyle = EdgeStyle(
            shape: shape,
            style: style,
            label: label,
            offset: offset
        )
        edgeStyleDict[index] = edgeStyle
        return self
    }
    
    public func setFaceStyle(
        style: PathStyle? = nil,
        label: LabelStyle? = nil
    ) -> Points {
        let style = FaceStyle(
            style: style,
            label: label
        )
        self.faceStyleDict[0] = style
        return self
    }
    
    public func useColorfulLabel(_ value: Bool) -> Self {
        self.useColorfulLabel = value
        return self
    }

    // MARK: - modifier
    public func show(_ option: DisplayOptions) -> Self {
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
            displayOptions: displayOptions,
            labelStyle: labelStyle,
            useColorfulLabel: useColorfulLabel
        )
    }
}

extension Points: DebugRenderable {
    public var debugBounds: CGRect? {
        guard let bounds = points.bounds else { return nil }
        return bounds * transform
    }
    public func render(with transform: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        if displayOptions.contains(.face) {
            face.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
        }
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
        .setVertexStyle(at: 0, shape: .shape(Circle(radius: 2)), label: "Corner")
        .setVertexStyle(at: 1, style: .init(color: .red), label: .coordinate())
        .setEdgeStyle(at: 2, shape: .arrow(.doubleArrow), style: .init(color: .red, mode: .fill), label: .string("edge", rotatable: true))
        .setFaceStyle(label: .string("face", at: .center))
        .show([.vertex, .edge, .face])
    }
    .coordinateVisible(true)
    .coordinateStyle(.default)
    .coordinateSystem(.yDown)
    //.zoom(1.5, aroundCenter: .init(x: 10, y: 23))
}
