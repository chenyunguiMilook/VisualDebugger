//
//  Point.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/5.
//

//
//  Dot.swift
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

public typealias VDot = Dot

public final class Dot: VertexDebugger {
    
    public var position: CGPoint
    private var customVertexStyle: VertexStyle?
    
    public lazy var vertex: Vertex = {
        createVertex(index: 0, position: position, vertexStyle: customVertexStyle)
    }()
    
    public init(
        _ position: CGPoint,
        name: String? = nil,
        transform: Matrix2D = .identity,
        color: AppColor = .yellow,
        vertexShape: VertexShape = .shape(Circle(radius: 2))
    ) {
        self.position = position
        super.init(name: name, transform: transform, color: color, vertexShape: vertexShape)
    }
    
    public func setStyle(
        shape: VertexShape? = nil,
        style: Style? = nil,
        label: Description? = nil
    ) -> Dot {
        self.customVertexStyle = VertexStyle(shape: shape, style: style, label: label)
        return self
    }
    
    public func setStyle(_ style: VertexStyle) -> Dot {
        self.customVertexStyle = style
        return self
    }
}

extension Dot: Transformable {
    public func applying(transform: Matrix2D) -> Dot {
        Dot(
            self.position,
            transform: self.transform * transform,
            color: self.color,
            vertexShape: self.vertexShape
        )
    }
}

extension Dot: DebugRenderable {
    public var debugBounds: CGRect? {
        let rect = CGRect(center: position, size: CGSize(width: 4, height: 4))
        return rect * transform
    }
    
    public func render(with transform: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        vertex.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    DebugView {
        Dot(.init(x: 150, y: 150), vertexShape: .shape(Circle(radius: 2)))
            .setStyle(label: "Hello")
        Dot(.init(x: 200, y: 100), color: .red, vertexShape: .index)
    }
    .coordinateVisible(true)
    .coordinateStyle(.default)
    .coordinateSystem(.yDown)
}
