//
//  PointElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import CoreGraphics

public final class PointElement {
    // TODO: support style inherient
    
    public var shape: StaticRendable
    public var label: TextElement?
    
    public init(shape: StaticRendable, label: TextElement? = nil) {
        self.shape = shape
        self.label = label
    }
}

extension PointElement: StaticRendable {
    public var contentBounds: CGRect {
        var bounds = shape.contentBounds
        if let label {
            bounds = bounds.union(label.contentBounds)
        }
        return bounds
    }
    
    public func render(
        with transform: Matrix2D,
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int?
    ) {
        var array: [StaticRendable] = [shape]
        if let label { array.append(label) }
        for element in array {
            element.render(
                with: transform,
                in: context,
                scale: scale,
                contextHeight: contextHeight
            )
        }
    }
    
    public func clone() -> PointElement {
        PointElement(shape: shape.clone(), label: label?.clone())
    }
}

//public typealias StaticPointElement = StaticRenderElement<PointElement>
public typealias PointRenderElement = StaticRenderElement<PointElement>
