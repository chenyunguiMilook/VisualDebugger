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

final class CoordinateRenderElement: ContextRenderable {
    
    let coordinate: Coordinate
    let coordSystem: CoordinateSystem2D
    let style: CoordinateStyle
    
    lazy var xAxis = AxisRenderElement(axis: coordinate.xAxis, color: style.xAxisColor, coord: coordSystem)
    lazy var yAxis = AxisRenderElement(axis: coordinate.yAxis, color: style.yAxisColor, coord: coordSystem)
    lazy var origin = getOriginElement()
    
    init(
        coordinate: Coordinate,
        coordSystem: CoordinateSystem2D,
        style: CoordinateStyle
    ) {
        self.coordinate = coordinate
        self.coordSystem = coordSystem
        self.style = style
    }
    
    func render(
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
        let shape = ShapeElement(renderer: Circle(radius: 1), style: shapeStyle)
        var labelStyle = TextRenderStyle.originLabel
            labelStyle.textColor = style.originColor
        let label = TextElement(source: .string("O"), style: labelStyle)
        let point = PointElement(shape: shape, label: label)
        return .init(content: point, position: coordinate.origin)
    }
}
