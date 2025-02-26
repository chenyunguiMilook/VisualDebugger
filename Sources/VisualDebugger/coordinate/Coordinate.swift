//
//  Coordinate.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


import Foundation

public struct Coordinate {
    
    public let segmentValue: CGFloat
    public let valueRect: CGRect
    public let origin: CGPoint
    public let xAxis: Axis
    public let yAxis: Axis
    
    public init(rect: CGRect, numSegments: Int) {
        let maxValue = max(rect.size.width, rect.size.height)
        self.segmentValue = CGFloat(getDivision(Double(maxValue), segments: numSegments))
        let xAxisData = AxisData(min: rect.minX, max: rect.maxX, segmentValue: segmentValue)
        let yAxisData = AxisData(min: rect.minY, max: rect.maxY, segmentValue: segmentValue)
        self.valueRect = CGRect(
            x: xAxisData.startValue,
            y: yAxisData.startValue,
            width: xAxisData.lengthValue,
            height: yAxisData.lengthValue
        )
        let originY: CGFloat = (valueRect.minY < 0 && valueRect.maxY >= 0) ? 0 : yAxisData.startValue
        let originX: CGFloat = (valueRect.minX < 0 && valueRect.maxX >= 0) ? 0 : xAxisData.startValue
        let origin = CGPoint(x: originX, y: originY)
        self.xAxis = xAxisData.getAxis(type: .x(origin: origin))
        self.yAxis = yAxisData.getAxis(type: .y(origin: origin))
        self.origin = origin
    }
    
    public func renderElements(_ coordinateSystem: CoordinateSystem2D) -> [any Debuggable] {
        [originElement()] +
        xAxis.renderElements(coordinateSystem: coordinateSystem) +
        yAxis.renderElements(coordinateSystem: coordinateSystem)
    }
    
    func originElement() -> TextRenderElement {
        TextRenderElement(text: "O", style: .originLabel, position: origin)
    }
}
