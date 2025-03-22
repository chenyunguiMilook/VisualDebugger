//
//  DebugContext.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//
import Foundation
import CoreGraphics

public final class DebugContext {
    
    public class Config {
        public let minWidth: Double
        public let numSegments: Int
        public let showOrigin: Bool
        public var showCoordinate: Bool
        public var showLog: Bool
        public var showGlobalElements: Bool
        public var coordinateSystem: CoordinateSystem2D
        public var coordinateStyle: CoordinateStyle
        public let bgElements: [any DebugRenderable]? // such as background elements
        
        public init(
            minWidth: Double = 250,
            numSegments: Int = 5,
            showOrigin: Bool = false,
            showCoordinate: Bool = true,
            showLog: Bool = true,
            showGlobalElements: Bool = true,
            coordinateSystem: CoordinateSystem2D = .yDown,
            coordinateStyle: CoordinateStyle = .default,
            bgElements: [any DebugRenderable]? = nil
        ) {
            self.minWidth = minWidth
            self.numSegments = numSegments
            self.showOrigin = showOrigin
            self.showCoordinate = showCoordinate
            self.showLog = showLog
            self.showGlobalElements = showGlobalElements
            self.coordinateSystem = coordinateSystem
            self.coordinateStyle = coordinateStyle
            self.bgElements = bgElements
        }
    }
    
    private var margin: CGFloat = 40
    private var colorIndex: Int = 0
    
    private var valueToRender: Matrix2D
    private var renderToValue: Matrix2D { valueToRender.inverted() }
    private var renderRect: CGRect { coordinate.valueRect * valueToRender }
    private var _flip: Matrix2D
    let coordinate: Coordinate
    lazy var coordinateElement = CoordinateRenderElement(coordinate: coordinate, coordSystem: coordinateSystem, style: coordinateStyle)
    
    public var transform: Matrix2D = .identity
    
    private let config: Config
    
    public var minWidth: Double { config.minWidth }
    public var numSegments: Int { config.numSegments }
    public var showOrigin: Bool { config.showOrigin }
    public var showCoordinate: Bool {
        get { config.showCoordinate }
        set { config.showCoordinate = newValue }
    }
    public var showLog: Bool {
        get { config.showLog }
        set { config.showLog = newValue }
    }
    public var showGlobalElements: Bool {
        get { config.showGlobalElements }
        set { config.showGlobalElements = newValue }
    }
    public var coordinateSystem: CoordinateSystem2D {
        get { config.coordinateSystem }
        set { config.coordinateSystem = newValue }
    }
    public var coordinateStyle: CoordinateStyle {
        get { config.coordinateStyle }
        set { config.coordinateStyle = newValue }
    }
    
    public var elements: [any ContextRenderable] = []
    public private(set) var frame: CGRect
    
    public convenience init(
        minWidth: Double = 250,
        numSegments: Int = 5,
        showOrigin: Bool = false,
        showCoordinate: Bool = true,
        showLog: Bool = true,
        showGlobalElements: Bool = true,
        coordinateSystem: CoordinateSystem2D = .yDown,
        coordinateStyle: CoordinateStyle = .default,
        elements: [any DebugRenderable]
    ) {
        let config = Config(
            minWidth: minWidth,
            numSegments: numSegments,
            showOrigin: showOrigin,
            showCoordinate: showCoordinate,
            showLog: showLog,
            showGlobalElements: showGlobalElements, 
            coordinateSystem: coordinateSystem,
            coordinateStyle: coordinateStyle
        )
        let debugRect = elements.debugBounds ?? CGRect(origin: .zero, size: .unit)
        self.init(debugRect: debugRect, elements: elements, config: config)
    }
    
    public convenience init(
        config: Config,
        elements: [any DebugRenderable]
    ) {
        var array = config.bgElements ?? []
            array.append(contentsOf: elements)
        let debugRect = array.debugBounds ?? CGRect(origin: .zero, size: .unit)
        self.init(debugRect: debugRect, elements: elements, config: config)
    }
    
    public convenience init(
        debugRect: CGRect,
        elements: [any ContextRenderable],
        minWidth: Double = 250,
        numSegments: Int = 5,
        showOrigin: Bool = false,
        showCoordinate: Bool = true,
        showLog: Bool = true,
        showGlobalElements: Bool = true,
        coordinateSystem: CoordinateSystem2D = .yDown,
        coordinateStyle: CoordinateStyle = .default
    ) {
        let config = Config(
            minWidth: minWidth,
            numSegments: numSegments,
            showOrigin: showOrigin,
            showCoordinate: showCoordinate,
            showLog: showLog,
            showGlobalElements: showGlobalElements,
            coordinateSystem: coordinateSystem,
            coordinateStyle: coordinateStyle
        )
        self.init(debugRect: debugRect, elements: elements, config: config)
    }
    
    public init(
        debugRect: CGRect,
        elements: [any ContextRenderable],
        config: Config = .init()
    ) {
        self.config = config
        var area = debugRect
        if area.width == 0 { area.size.width = 1 }
        if area.height == 0 { area.size.height = 1 }
        area = config.showOrigin ? area.rectFromOrigin : area
        
        let coordinate = Coordinate(rect: area, numSegments: config.numSegments)
        
        // calculate the proper segment length
        let minSegmentLength = config.minWidth / CGFloat(config.numSegments)
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
        self.valueToRender = stretchFit(rect: valueRect, into: renderRect)
        self._flip = Matrix2D(scaleX: 1, scaleY: -1, aroundCenter: renderRect.center)
        self.coordinate = coordinate
        self.frame = frame
        self.elements = elements
    }
    
    public func append(_ element: DebugRenderable) {
        self.elements.append(element)
    }
    
    @discardableResult
    public func zoom(_ zoom: Double, aroundCenter center: CGPoint? = nil) -> Self {
        let center = (center ?? coordinate.valueRect.center) * valueToRender
        self.transform = Matrix2D(scale: zoom, aroundCenter: center)
        return self
    }
    
    @discardableResult
    public func zoom(to rect: CGRect) -> Self {
        // should calculate render transform
        let zoomRenderRect = rect * valueToRender
        self.transform = zoomRenderRect.fit(to: renderRect, config: .aspectFillInside)
        return self
    }

    public func render(
        elements additional: [any ContextRenderable]? = nil,
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int
    ) {
        var transform = valueToRender * self.transform
        if coordinateSystem == .yUp {
            transform = transform * _flip
        }
        if showCoordinate {
            coordinateElement.render(
                with: transform,
                in: context,
                scale: scale,
                contextHeight: contextHeight)
        }
        if let bgElements = config.bgElements {
            for element in bgElements {
                element.render(
                    with: transform,
                    in: context,
                    scale: scale,
                    contextHeight: contextHeight
                )
            }
        }
        var logs: [Logger.Log] = Logger.default.logs
        for element in self.elements {
            logs.append(contentsOf: element.logs)
            element.render(
                with: transform,
                in: context,
                scale: scale,
                contextHeight: contextHeight
            )
        }
        if let additional {
            for element in additional {
                logs.append(contentsOf: element.logs)
                element.render(
                    with: transform,
                    in: context,
                    scale: scale,
                    contextHeight: contextHeight
                )
            }
        }
        if showGlobalElements {
            DebugManager.shared.render(
                with: transform,
                in: context,
                scale: scale,
                contextHeight: contextHeight
            )
        }
        
        if showLog {
            logs.render(in: context, scale: scale, contextHeight: contextHeight)
        }
    }
    
    public func getImage(scale: CGFloat, elements: [any ContextRenderable]? = nil) -> AppImage? {
        let cgImage = withImageContext(
            width: frame.width,
            height: frame.height,
            scale: scale,
            bgColor: AppColor.black.cgColor
        ) { context in
            self.render(
                elements: elements,
                in: context,
                scale: scale,
                contextHeight: Int(frame.height * scale)
            )
        }
        guard let cgImage else { return nil }
        #if os(iOS)
        return AppImage(cgImage: cgImage, scale: scale, orientation: .up)
        #elseif os(macOS)
        return AppImage(cgImage: cgImage, size: frame.size)
        #endif
    }
    
    @objc public func debugQuickLookObject() -> Any {
        var scale: Double = 1
        #if os(iOS)
        scale = 2
        #endif
        if let image = getImage(scale: scale) {
            return image
        } else {
            return "failed to render image"
        }
    }
}
