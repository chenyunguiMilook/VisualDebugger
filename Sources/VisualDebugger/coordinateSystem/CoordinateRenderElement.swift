//
//  CoordinateRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/4.
//

import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class CoordinateRenderElement: ContextRenderable {
    
    public let coordinate: Coordinate
    public let coordSystem: CoordinateSystem2D
    public let style: CoordinateStyle
    
    lazy var xAxis = AxisRenderElement(axis: coordinate.xAxis, color: style.xAxisColor, coord: coordSystem)
    lazy var yAxis = AxisRenderElement(axis: coordinate.yAxis, color: style.yAxisColor, coord: coordSystem)
    lazy var origin = getOriginElement()
    
    public init(
        coordinate: Coordinate,
        coordSystem: CoordinateSystem2D,
        style: CoordinateStyle
    ) {
        self.coordinate = coordinate
        self.coordSystem = coordSystem
        self.style = style
    }
    
    public func render(
        with transform: Matrix2D,
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int?
    ) {
        xAxis.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
        yAxis.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
        origin.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
    }
    
    private func getOriginElement() -> StaticRenderElement<PointElement> {
        let shapeStyle = ShapeRenderStyle(fill: .init(color: style.originColor))
        let shape = ShapeElement(source: .shape(.circle, size: .init(width: 2, height: 2), anchor: .midCenter), style: shapeStyle)
        var labelStyle = TextRenderStyle.originLabel
            labelStyle.textColor = style.originColor
        let label = TextElement(source: .string("O"), style: labelStyle)
        let point = PointElement(shape: shape, label: label)
        return .init(content: point, position: coordinate.origin)
    }
}
