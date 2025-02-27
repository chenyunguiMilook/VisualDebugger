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
        case .arrow(let style, _):
            switch style {
            case .triangle:
                true
            default:
                false
            }
        case .rect: true
        case .circle: true
        case .range: false
        }
    }
    
    func getRenderElement(size: Double, color: AppColor, lineWidth: Double) -> ContextRenderable {
        func getStyle(filled: Bool) -> ShapeRenderStyle {
            if filled {
                ShapeRenderStyle(fill: .init(color: color))
            } else {
                ShapeRenderStyle(stroke: .init(color: color, style: .init(lineWidth: lineWidth)))
            }
        }
        
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
            return MarkRenderElement(
                path: path,
                style: getStyle(filled: filled),
                position: .zero,
                rotatable: true
            )
        case .rect(let filled):
            let rect = CGRect(anchor: .midRight, center: .zero, size: .init(width: size, height: size))
            let path = AppBezierPath(rect: rect)
            return MarkRenderElement(
                path: path,
                style: getStyle(filled: filled),
                position: .zero,
                rotatable: true
            )
        case .circle(let filled):
            let rect = CGRect(anchor: .midRight, center: .zero, size: .init(width: size, height: size))
            let path = AppBezierPath(ovalIn: rect)
            return MarkRenderElement(
                path: path,
                style: getStyle(filled: filled),
                position: .zero,
                rotatable: true
            )
        case .range: // looks like: >|
            let path = AppBezierPath()
            let half = size / 2
            path.move(to: .init(x: 0, y: -half))
            path.addLine(to: .init(x: 0, y: half))
            path.move(to: .init(x: -size, y: -half))
            path.addLine(to: .zero)
            path.addLine(to: .init(x: -size, y: half))
            return MarkRenderElement(
                path: path,
                style: getStyle(filled: false),
                position: .zero,
                rotatable: true
            )
        }
    }
}
