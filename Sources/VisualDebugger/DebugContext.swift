//
//  DebugContext.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//
import Foundation
import CoreGraphics

// TODO: support zoom to specified area
public final class DebugContext {
    
    private var margin: CGFloat = 40
    private var colorIndex: Int = 0
    
    private var _valueToRender: Matrix2D
    private var _flip: Matrix2D
    private var _coordinate: Coordinate
    lazy var coordinate = CoordinateRenderElement(coordinate: _coordinate, coordSystem: coordinateSystem, style: coordinateStyle)
    
    public var transform: Matrix2D = .identity
    public var showCoordinate: Bool
    public var coordinateSystem: CoordinateSystem2D
    public var coordinateStyle: CoordinateStyle
    public var elements: [any ContextRenderable] = []
    public private(set) var frame: CGRect
    
    public convenience init(
        elements: [any Debuggable],
        minWidth: Double = 250,
        numSegments: Int = 5,
        showOrigin: Bool = false,
        showCoordinate: Bool = true,
        coordinateSystem: CoordinateSystem2D = .yDown,
        coordinateStyle: CoordinateStyle = .default
    ) {
        let debugRect = elements.debugBounds ?? CGRect(origin: .zero, size: .unit)
        self.init(
            debugRect: debugRect,
            elements: elements,
            minWidth: minWidth,
            numSegments: numSegments,
            showOrigin: showOrigin,
            showCoordinate: showCoordinate,
            coordinateSystem: coordinateSystem,
            coordinateStyle: coordinateStyle
        )
    }
    
    public init(
        debugRect: CGRect,
        elements: [any ContextRenderable],
        minWidth: Double = 250,
        numSegments: Int = 5,
        showOrigin: Bool = false,
        showCoordinate: Bool = true,
        coordinateSystem: CoordinateSystem2D = .yDown,
        coordinateStyle: CoordinateStyle = .default
    ) {
        var area = debugRect
        if area.width == 0 { area.size.width = 1 }
        if area.height == 0 { area.size.height = 1 }
        area = showOrigin ? area.rectFromOrigin : area
        
        let coordinate = Coordinate(rect: area, numSegments: numSegments)
        
        // calculate the proper segment length
        let minSegmentLength = minWidth / CGFloat(numSegments)
        var segmentLength = minSegmentLength
        if let maxLabelWidth = coordinate.xAxis.estimateMaxLabelWidth {
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
        self.coordinateStyle = coordinateStyle
        self.frame = frame
        self.elements = elements
    }
    
    public func append(_ element: Debuggable) {
        self.elements.append(element)
    }
    
    public func zoom(_ zoom: Double, aroundCenter center: CGPoint? = nil) {
        let center = center ?? _coordinate.valueRect.center
        self.transform = self.transform * Matrix2D(scale: zoom, aroundCenter: center)
    }

    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int) {
        var transform = self.transform * _valueToRender
        if coordinateSystem == .yUp {
            transform = transform * _flip
        }
        if showCoordinate {
            coordinate.render(
                with: transform,
                in: context,
                scale: scale,
                contextHeight: contextHeight)
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
