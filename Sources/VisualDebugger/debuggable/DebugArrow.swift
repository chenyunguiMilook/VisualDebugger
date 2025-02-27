//
//  DebugArrows.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/27.
//

import Foundation
import CoreGraphics
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public final class DebugArrow {
    
    public enum Style {
        case simple(color: AppColor, headSize: Double, bodyWidth: Double)
        case triangle(color: AppColor, headSize: Double, bodyWidth: Double)
        case doubleEnded(color: AppColor, headSize: Double, bodyWidth: Double)
        case custom(lineStyle: ShapeRenderStyle, arrowStyle: ShapeRenderStyle, options: ArrowRenderElement.ArrowOptions)
    }
    
    public let head: CGPoint
    public let tail: CGPoint
    public let style: Style
    
    public init(
        tail: CGPoint,
        head: CGPoint,
        style: Style = .simple(color: .yellow, headSize: 8, bodyWidth: 1)
    ) {
        self.tail = tail
        self.head = head
        self.style = style
    }
}

extension DebugArrow: Debuggable {
    public var debugBounds: CGRect? {
        let points = [tail, head]
        return points.bounds
    }
    
    public func applying(transform: Matrix2D) -> DebugArrow {
        return DebugArrow(tail: tail * transform, head: head * transform, style: style)
    }
    
    public func render(in context: CGContext, contentScaleFactor: CGFloat, contextHeight: Int?) {
        let element = style.getRenderElement(tail: tail, head: head)
        element.render(in: context, contentScaleFactor: contentScaleFactor, contextHeight: contextHeight)
    }
}

extension DebugArrow.Style {
    func getRenderElement(tail: CGPoint, head: CGPoint) -> ContextRenderable {
        switch self {
        case .simple(let color, let headSize, let bodyWidth):
            let lineStyle = ShapeRenderStyle(stroke: .init(color: color, style: .init(lineWidth: bodyWidth)))
            let arrowStyle = ShapeRenderStyle(stroke: .init(color: color, style: .init(lineWidth: 1)))
            return ArrowRenderElement(
                startPoint: tail,
                endPoint: head,
                headSize: headSize,
                bodyWidth: bodyWidth,
                lineStyle: lineStyle,
                arrowStyle: arrowStyle,
                options: .head
            )
            
        case .triangle(let color, let headSize, let bodyWidth):
            let lineStyle = ShapeRenderStyle(stroke: .init(color: color, style: .init(lineWidth: bodyWidth)))
            let arrowStyle = ShapeRenderStyle(
                stroke: .init(color: color, style: .init(lineWidth: 1)),
                fill: .init(color: color)
            )
            return ArrowRenderElement(
                startPoint: tail,
                endPoint: head,
                headSize: headSize,
                bodyWidth: bodyWidth,
                lineStyle: lineStyle,
                arrowStyle: arrowStyle,
                options: .head
            )
            
        case .doubleEnded(let color, let headSize, let bodyWidth):
            let lineStyle = ShapeRenderStyle(stroke: .init(color: color, style: .init(lineWidth: bodyWidth)))
            let arrowStyle = ShapeRenderStyle(
                stroke: .init(color: color, style: .init(lineWidth: 1)),
                fill: .init(color: color)
            )
            return ArrowRenderElement(
                startPoint: tail,
                endPoint: head,
                headSize: headSize,
                bodyWidth: bodyWidth,
                lineStyle: lineStyle,
                arrowStyle: arrowStyle,
                options: [.head, .tail]
            )
            
        case .custom(let lineStyle, let arrowStyle, let options):
            return ArrowRenderElement(
                startPoint: tail,
                endPoint: head,
                lineStyle: lineStyle,
                arrowStyle: arrowStyle,
                options: options
            )
        }
    }
}


// Example demonstrating different arrow styles
#Preview(traits: .fixedLayout(width: 500, height: 400)) {
    DebugView(elements: [
        // Simple arrow
        DebugArrow(
            tail: .init(x: 20, y: 20),
            head: .init(x: 100, y: 20),
            style: .simple(color: .red, headSize: 10, bodyWidth: 2)
        ),
        
        // Triangle arrow
        DebugArrow(
            tail: .init(x: 20, y: 60),
            head: .init(x: 100, y: 60),
            style: .triangle(color: .green, headSize: 10, bodyWidth: 2)
        ),
        
        // Double-ended arrow
        DebugArrow(
            tail: .init(x: 20, y: 100),
            head: .init(x: 100, y: 100),
            style: .doubleEnded(color: .blue, headSize: 10, bodyWidth: 2)
        ),
        
        // Custom arrow with specific options
        DebugArrow(
            tail: .init(x: 20, y: 140),
            head: .init(x: 100, y: 140),
            style: .custom(
                lineStyle: ShapeRenderStyle(stroke: .init(color: .purple, style: .init(lineWidth: 2))),
                arrowStyle: ShapeRenderStyle(
                    stroke: .init(color: .orange, style: .init(lineWidth: 1)),
                    fill: .init(color: .orange)
                ),
                options: [.head, .tail]
            )
        ),
        
        // Create a flow diagram with arrows and points
        DebugPoints(points: [
            .init(x: 50, y: 180),
            .init(x: 50, y: 230),
            .init(x: 100, y: 230),
            .init(x: 100, y: 180)
        ], style: .circle(color: .yellow, radius: 10)),
        
        DebugArrow(
            tail: .init(x: 50, y: 180),
            head: .init(x: 50, y: 230),
            style: .triangle(color: .purple, headSize: 8, bodyWidth: 1.5)
        ),
        DebugArrow(
            tail: .init(x: 50, y: 230),
            head: .init(x: 100, y: 230),
            style: .triangle(color: .purple, headSize: 8, bodyWidth: 1.5)
        ),
        DebugArrow(
            tail: .init(x: 100, y: 230),
            head: .init(x: 100, y: 180),
            style: .triangle(color: .purple, headSize: 8, bodyWidth: 1.5)
        ),
        DebugArrow(
            tail: .init(x: 100, y: 180),
            head: .init(x: 50, y: 180),
            style: .triangle(color: .purple, headSize: 8, bodyWidth: 1.5)
        )
    ], numSegments: 8, coordinateSystem: .yDown)
}
