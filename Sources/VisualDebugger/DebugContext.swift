//
//  DebugContext.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//
import Foundation
import CoreGraphics

public final class DebugContext {
    
    private var margin: CGFloat = 40
    private var colorIndex: Int = 0
    private var coordElements: [any Debuggable]
    
    private var _valueToRender: Matrix2D
    private var _flip: Matrix2D
    private var _coordinate: Coordinate
    
    public var valueToRender: Matrix2D {
        switch coordinateSystem {
        case .yDown: _valueToRender
        case .yUp: _valueToRender * _flip
        }
    }
    public var showCoordinate: Bool
    public var coordinateSystem: CoordinateSystem2D {
        didSet {
            self.coordElements = _coordinate.renderElements(coordinateSystem)
        }
    }
    public var elements: [any Debuggable] = []
    public private(set) var frame: CGRect
    
    public convenience init(
        elements: [any Debuggable],
        minWidth: Double = 250,
        numSegments: Int = 5,
        showOrigin: Bool = false,
        showCoordinate: Bool = true,
        coordinateSystem: CoordinateSystem2D = .yDown
    ) {
        let debugRect = elements.debugBounds ?? CGRect(origin: .zero, size: .unit)
        self.init(
            debugRect: debugRect,
            minWidth: minWidth,
            numSegments: numSegments,
            showOrigin: showOrigin,
            showCoordinate: showCoordinate,
            coordinateSystem: coordinateSystem
        )
        self.elements = elements
    }
    
    public init(
        debugRect: CGRect,
        minWidth: Double = 250,
        numSegments: Int = 5,
        showOrigin: Bool = false,
        showCoordinate: Bool = true,
        coordinateSystem: CoordinateSystem2D = .yDown
    ) {
        var area = debugRect
        if area.width == 0 { area.size.width = 1 }
        if area.height == 0 { area.size.height = 1 }
        area = showOrigin ? area.rectFromOrigin : area
        
        let coordinate = Coordinate(rect: area, numSegments: numSegments)
        
        // calculate the proper segment length
        let minSegmentLength = minWidth / CGFloat(numSegments)
        var segmentLength = minSegmentLength
        if let maxLabelWidth = coordinate.xAxis.estimateMaxLabelWidth(with: .xAxisLabel) {
            segmentLength = max(maxLabelWidth, segmentLength)
        }
        segmentLength += 4
        
        // calculate the matrix for transform value from value space to render space
        let scale = segmentLength / coordinate.segmentValue
        let valueRect = coordinate.valueRect
        let canvasWidth = valueRect.width * scale + self.margin * 2
        let canvasHeight = valueRect.height * scale + self.margin * 2
        let frame = CGRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight)
        let renderRect = frame.shrinked(self.margin)
        self._valueToRender = stretchFit(rect: valueRect, into: renderRect)
        self._flip = Matrix2D(scaleX: 1, scaleY: -1, aroundCenter: renderRect.center)
        self._coordinate = coordinate
        self.showCoordinate = showCoordinate
        self.coordinateSystem = coordinateSystem
        self.coordElements = coordinate.renderElements(coordinateSystem)
        self.frame = frame
    }
    
    public func append(_ element: Debuggable) {
        self.elements.append(element)
    }
    
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int) {
        let transform = self.valueToRender
        if showCoordinate {
            for element in coordElements {
                element.render(
                    with: transform,
                    in: context,
                    scale: scale,
                    contextHeight: contextHeight
                )
            }
        }
        for element in elements {
            element.render(
                with: transform,
                in: context,
                scale: scale,
                contextHeight: contextHeight
            )
        }
    }
    
    public func getImage(scale: CGFloat) -> AppImage? {
        let cgImage = withImageContext(
            width: frame.width,
            height: frame.height,
            scale: scale,
            bgColor: AppColor.black.cgColor
        ) { context in
            self.render(in: context, scale: scale, contextHeight: Int(frame.height))
        }
        guard let cgImage else { return nil }
        #if os(iOS)
        return AppImage(cgImage: cgImage)
        #elseif os(macOS)
        return AppImage(cgImage: cgImage, size: frame.size)
        #endif
    }
    
    @objc public func debugQuickLookObject() async -> Any {
        if let image = getImage(scale: 1) {
            return image
        } else {
            return "failed to render image"
        }
    }
}
