//
//  XAxis.swift
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

extension Int {
    @usableFromInline
    static let markPrecision: Int = 6
}

public final class AxisRenderElement: ContextRenderable {
    public static let markLength: Double = 6

    public let axis: Axis
    public let color: AppColor
    public let coord: CoordinateSystem2D
    
    lazy var markStyle = ShapeRenderStyle(
        stroke: .init(color: color, style: .init(lineWidth: 1))
    )
    lazy var arrowStyle = ShapeRenderStyle(
        stroke: .init(color: color, style: .init(lineWidth: 1)),
        fill: nil
    )
    lazy var labelStyle = TextRenderStyle(
        font: AppFont(name: "HelveticaNeueInterface-Thin", size: 10) ?? AppFont.systemFont(ofSize: 10),
        insets: .zero,
        margin: AppEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
        anchor: .topCenter,
        textColor: color
    )
    
    lazy var marks = createMarks()
    lazy var arrow = axis.getElement(style: arrowStyle)
    
    public init(
        axis: Axis,
        color: AppColor = .lightGray,
        coord: CoordinateSystem2D
    ) {
        self.axis = axis
        self.color = color
        self.coord = coord
    }
    
    public func render(
        with transform: Matrix2D,
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int?
    ) {
        for mark in marks {
            mark.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
        }
        self.arrow.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
    }
    
    func createMarks() -> [StaticRenderElement<PointElement>] {
        return axis.marks.compactMap { mark in
            if mark.position == axis.origin.position { return nil }
            return mark.getElement(
                length: Self.markLength,
                precision: .markPrecision,
                coord: coord,
                markStyle: markStyle,
                labelStyle: labelStyle
            )
        }
    }
}

extension Axis.Mark {
    
    func estimateSize() -> CGSize {
        let text = TextSource.number(value: self.value, precision: .markPrecision).string
        return TextRenderStyle.xAxisLabel.getTextSize(text: text)
    }
    
    func getElement(
        length: Double,
        precision: Int,
        coord: CoordinateSystem2D,
        markStyle: ShapeRenderStyle,
        labelStyle: TextRenderStyle
    ) -> StaticRenderElement<PointElement> {
        var textStyle = labelStyle
        let path = AppBezierPath()
        path.move(to: .zero)
        switch type {
        case .x:
            switch coord {
            case .yUp:
                path.addLine(to: .init(x: 0, y: -length))
                textStyle.setTextLocation(.bottom)
            case .yDown:
                path.addLine(to: .init(x: 0, y: length))
                textStyle.setTextLocation(.top)
            }
        case .y:
            path.addLine(to: .init(x: length, y: 0))
            textStyle.setTextLocation(.left)
        }
        
        let shape = ShapeElement(renderer: path, style: markStyle)
        let label = TextElement(source: .number(value: self.value, precision: precision), style: textStyle)
        let point = PointElement(shape: shape, label: label)
        return .init(content: point, position: position)
    }
}

extension Axis {
    func getElement(style: ShapeRenderStyle) -> SegmentRenderElement {
        return SegmentRenderElement(start: start.position, end: end.position, segmentShape: Arrow(), segmentStyle: style)
    }
}
