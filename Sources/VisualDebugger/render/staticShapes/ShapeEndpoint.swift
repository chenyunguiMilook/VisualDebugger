//
//  ShapePoint.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import CoreGraphics

public final class ShapeEndpoint: ShapeElement {

    public var shape: ShapeType
    public var size: CGSize
    public var anchor: Anchor
    
    public init(shape: ShapeType, size: CGSize, anchor: Anchor, style: ShapeRenderStyle) {
        self.shape = shape
        self.size = size
        self.anchor = anchor
        super.init(path: shape.createPath(size: size, anchor: anchor), style: style)
    }
}

