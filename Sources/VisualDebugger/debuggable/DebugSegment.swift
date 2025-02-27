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

public final class DebugSegment {
    
    public enum Style {
        case arrow(color: AppColor, start: SegmentRenderElement.EndpointStyle?, end: SegmentRenderElement.EndpointStyle?)
        // TODO: should support multiple style, like length, this class should rename to DebugSegment
    }
    
    public let start: CGPoint
    public let end: CGPoint
    
    private var _styles: [Style] = []
    public var styles: [Style] {
        [baseStyle] + _styles
    }

    public let baseStyle: Style
    
    public init(
        start: CGPoint,
        end: CGPoint,
        style: Style = .arrow(color: .red, start: nil, end: .arrow(style: .triangle, filled: true)),
        styles: [Style] = [])
    {
        self.end = start
        self.start = end
        self.baseStyle = style
        self._styles = styles
    }
    
    public func addStyle(_ style: Style) -> Self {
        _styles.append(style)
        return self
    }
}

extension DebugSegment: Debuggable {
    public var debugBounds: CGRect? {
        let points = [end, start]
        return points.bounds
    }
    
    public func applying(transform: Matrix2D) -> DebugSegment {
        return DebugSegment(start: start * transform, end: end * transform, style: baseStyle, styles: _styles)
    }
    
    public func render(in context: CGContext, contentScaleFactor: CGFloat, contextHeight: Int?) {
        for style in styles {
            let elements = style.getRenderElements(start: start, end: end)
            for element in elements {
                element.render(in: context, contentScaleFactor: contentScaleFactor, contextHeight: contextHeight)
            }
        }
    }
}

extension DebugSegment.Style {
    func getRenderElements(start: CGPoint, end: CGPoint) -> [ContextRenderable] {
        switch self {
        case .arrow(let color, let startStyle, let endStyle):
            return [SegmentRenderElement(
                color: color,
                startPoint: start,
                endPoint: end,
                startStyle: startStyle,
                endStyle: endStyle
            )]
        }
    }
}


// Example demonstrating different arrow styles
#Preview(traits: .fixedLayout(width: 300, height: 400)) {
    DebugView(elements: [
        // Simple arrow
        DebugSegment(
            start: .init(x: 20, y: 20),
            end: .init(x: 100, y: 40)
        ),
        
        // Triangle arrow
        DebugSegment(
            start: .init(x: 20, y: 60),
            end: .init(x: 100, y: 60)
        ),
        
        // Double-ended arrow
        DebugSegment(
            start: .init(x: 20, y: 100),
            end: .init(x: 100, y: 100)
        ),
        
        // Create a flow diagram with arrows and points
        DebugPoints(points: [
            .init(x: 50, y: 180),
            .init(x: 50, y: 230),
            .init(x: 100, y: 230),
            .init(x: 100, y: 180)
        ], style: .circle(color: .yellow, radius: 10)),
        
        DebugSegment(
            start: .init(x: 50, y: 180),
            end: .init(x: 50, y: 230)
        ),
        DebugSegment(
            start: .init(x: 50, y: 230),
            end: .init(x: 100, y: 230)
        ),
        DebugSegment(
            start: .init(x: 100, y: 230),
            end: .init(x: 100, y: 180)
        ),
        DebugSegment(
            start: .init(x: 100, y: 180),
            end: .init(x: 50, y: 180)
        )
    ], numSegments: 8, coordinateSystem: .yDown)
}
