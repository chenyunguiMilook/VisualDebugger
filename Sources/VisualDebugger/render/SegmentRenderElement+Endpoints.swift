//
//  SegmentRenderElement+Endpoints.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/27.
//

import CoreGraphics

extension SegmentRenderElement {
    public enum EndpointStyle {
        public enum ArrowStyle {
            case triangle
            case topHalfTriangle
            case bottomHalfTriangle
        }
        
        case arrow(style: ArrowStyle, filled: Bool)
        case rect(filled: Bool)
        case circle(filled: Bool)
        case range // for measure distance
    }
}

extension SegmentRenderElement.EndpointStyle {
    
    var occupiedWidth: Bool {
        switch self {
        case .arrow: true
        case .rect: true
        case .circle: true
        case .range: false
        }
    }
    
    func getRenderElement(size: Double, color: AppColor, lineWidth: Double) -> ContextRenderable {
        // first get path at origin
        switch self {
        case .arrow(let style, let filled):
            let half = size / 2
            let p1: CGPoint
            let p2: CGPoint
            switch style {
            case .triangle:
                p1 = .init(x: -size, y: -half)
                p2 = .init(x: -size, y: half)
            case .topHalfTriangle:
                p1 = .init(x: -size, y: -half)
                p2 = .init(x: -size, y: 0)
            case .bottomHalfTriangle:
                p1 = .init(x: -size, y: 0)
                p2 = .init(x: -size, y: half)
            }
            let path = AppBezierPath()
            path.move(to: .zero)
            path.addLine(to: p1)
            path.addLine(to: p2)
            path.close()
            let rs = if filled {
                ShapeRenderStyle(fill: .init(color: color))
            } else {
                ShapeRenderStyle(stroke: .init(color: color, style: .init(lineWidth: lineWidth)))
            }
            return MarkRenderElement(
                path: path,
                style: rs,
                position: .zero,
                rotatable: true
            )
        case .rect:
            fatalError("need implementation")
        case .circle:
            fatalError("need implementation")
        case .range: // looks like: |<
            fatalError("need implementation")
        }
    }
}
