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
    
    public init(
        _ position: CGPoint,
        transform: Matrix2D = .identity,
        color: AppColor = .yellow,
        vertexShape: VertexShape = .shape(Circle(radius: 2))
    ) {
        self.position = position
        super.init(transform: transform, color: color, vertexShape: vertexShape)
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

extension Dot: Debuggable {
    public var debugBounds: CGRect? {
        let rect = CGRect(center: position, size: CGSize(width: 4, height: 4))
        return rect * transform
    }
    
    public func render(with transform: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        let vertex = createVertex(
            index: 0,
            position: position,
            shape: nil,
            style: nil,
            name: nil,
            nameLocation: nil,
            transform: self.transform
        )
        
        vertex.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    DebugView {
        Dot(.init(x: 150, y: 150), vertexShape: .shape(Circle(radius: 2)))
        Dot(.init(x: 200, y: 100), color: .red, vertexShape: .index)
    }
    .coordinateVisible(true)
    .coordinateStyle(.default)
    .coordinateSystem(.yDown)
}
