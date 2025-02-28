//
//  AnnotationRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/28.
//

import CoreGraphics


public struct AnnotationRenderElement: ContextRenderable {
    public enum Direction {
        case left, right, top, bottom
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    public let center: CGPoint
    public let annotation: String
    public let direction: Direction
    public let offset: Double
    public let style: TextRenderStyle
    
    public init(center: CGPoint, direction: Direction, offset: Double, annotation: String, style: TextRenderStyle) {
        self.center = center
        self.direction = direction
        self.offset = offset
        self.annotation = annotation
        self.style = style
    }
    
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        
    }
    
    public func applying(transform: Matrix2D) -> AnnotationRenderElement {
        fatalError("need implementation")
    }
}

