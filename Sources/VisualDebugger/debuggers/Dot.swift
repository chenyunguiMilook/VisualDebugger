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
import VisualUtils

public typealias VDot = Dot

public final class Dot: VertexDebugger {
    
    public var position: CGPoint
    
    public lazy var vertex: Vertex = {
        createVertex(index: 0, position: position)
    }()
    
    public init(
        _ position: CGPoint,
        name: String? = nil,
        transform: Matrix2D = .identity,
        color: AppColor = .yellow,
        vertexShape: VertexShape = .shape(Circle(radius: 2)),
        labelStyle: TextRenderStyle = .nameLabel,
        useColorfulLabel: Bool = false
    ) {
        self.position = position
        super.init(
            name: name,
            transform: transform,
            color: color,
            vertexShape: vertexShape,
            labelStyle: labelStyle, 
            useColorfulLable: useColorfulLabel
        )
    }
    
    public func setStyle(
        shape: VertexShape? = nil,
        style: PathStyle? = nil,
        label: LabelStyle? = nil
    ) -> Dot {
        self.vertexStyleDict[0] = VertexStyle(shape: shape, style: style, label: label)
        return self
    }
    
    public func setStyle(_ style: VertexStyle) -> Dot {
        self.vertexStyleDict[0] = style
        return self
    }
    
    public func useColorfulLabel(_ value: Bool) -> Dot {
        self.useColorfulLabel = value
        return self
    }
    
    public func log(_ message: Any..., level: Logger.Log.Level = .info) -> Self {
        self.logging(message, level: level)
        return self
    }
}

extension Dot: DebugRenderable {
    public var debugBounds: CGRect? {
        let rect = CGRect(center: position, size: CGSize(width: 4, height: 4))
        return rect * transform
    }
    
    public func render(
        with transform: Matrix2D,
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int?
    ) {
        vertex.render(
            with: self.transform * transform,
            in: context,
            scale: scale,
            contextHeight: contextHeight
        )
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    DebugView {
        Dot(.init(x: 150, y: 150), vertexShape: .shape(.circle(radius: 2)))
            .setStyle(style: .init(color: .green), label: "Hello")
            .applying(.init(translationX: 10, y: 10))
        Dot(.init(x: 200, y: 100), color: .red, vertexShape: .index)
    }
    .coordinateVisible(true)
    .coordinateStyle(.default)
    .coordinateSystem(.yDown)
}
