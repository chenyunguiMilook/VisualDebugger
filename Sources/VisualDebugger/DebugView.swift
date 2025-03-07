//
//  DebugView.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class DebugView: AppView {
    
    var context: DebugContext
    
    public var elements: [any ContextRenderable] {
        get { context.elements }
        set {
            context.elements = newValue
            self.refresh()
        }
    }
    
    public init(
        minWidth: Double = 250,
        numSegments: Int = 5,
        showOrigin: Bool = false,
        showCoordinate: Bool = true,
        coordinateSystem: CoordinateSystem2D = .yDown,
        coordinateStyle: CoordinateStyle = .default,
        elements: [any DebugRenderable]
    ) {
        let context = DebugContext(
            minWidth: minWidth,
            numSegments: numSegments,
            showOrigin: showOrigin,
            showCoordinate: showCoordinate,
            coordinateSystem: coordinateSystem,
            coordinateStyle: coordinateStyle,
            elements: elements
        )
        self.context = context
        super.init(frame: context.frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        #if os(macOS)
        self.wantsLayer = true
        #endif
    }
    
    public init(
        minWidth: Double = 250,
        numSegments: Int = 5,
        showOrigin: Bool = false,
        showCoordinate: Bool = true,
        coordinateSystem: CoordinateSystem2D = .yDown,
        coordinateStyle: CoordinateStyle = .default,
        @DebugRenderBuilder _ builder: () -> [any DebugRenderable]
    ) {
        let context = DebugContext(
            minWidth: minWidth,
            numSegments: numSegments,
            showOrigin: showOrigin,
            showCoordinate: showCoordinate,
            coordinateSystem: coordinateSystem,
            coordinateStyle: coordinateStyle,
            elements: builder()
        )
        self.context = context
        super.init(frame: context.frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        #if os(macOS)
        self.wantsLayer = true
        #endif
    }
    
    public init(
        debugRect: CGRect,
        minWidth: Double = 250,
        numSegments: Int = 5,
        showOrigin: Bool = false,
        showCoordinate: Bool = true,
        coordinateSystem: CoordinateSystem2D = .yDown,
        coordinateStyle: CoordinateStyle = .default,
        @RenderBuilder _ builder: () -> [any ContextRenderable]
    ) {
        let elements = builder()
        let context = DebugContext(
            debugRect: debugRect,
            elements: elements,
            minWidth: minWidth,
            numSegments: numSegments,
            showOrigin: showOrigin,
            showCoordinate: showCoordinate,
            coordinateSystem: coordinateSystem,
            coordinateStyle: coordinateStyle
        )
        self.context = context
        super.init(frame: context.frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        #if os(macOS)
        self.wantsLayer = true
        #endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func append(_ element: ContextRenderable) {
        self.elements.append(element)
    }
    
    public func coordinateVisible(_ show: Bool) -> DebugView {
        context.showCoordinate = show
        self.refresh()
        return self
    }
    
    public func coordinateSystem( _ coord: CoordinateSystem2D) -> DebugView {
        context.coordinateSystem = coord
        self.refresh()
        return self
    }
    
    public func coordinateStyle(_ style: CoordinateStyle) -> DebugView {
        context.coordinateStyle = style
        self.refresh()
        return self
    }
    
    public func zoom(_ zoom: Double, aroundCenter center: CGPoint? = nil) -> DebugView {
        self.context.zoom(zoom, aroundCenter: center)
        self.refresh()
        return self
    }
    
    private func refresh() {
        #if os(iOS)
        self.setNeedsDisplay()
        #elseif os(macOS)
        self.setNeedsDisplay(self.bounds)
        #endif
    }
    
    #if os(iOS)
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)
        let scale: CGFloat = self.contentScaleFactor
        let contextHeight = Int(bounds.height * scale)
        self.context.render(in: context, scale: scale, contextHeight: contextHeight)
    }
    #elseif os(macOS)
    
    public override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        let scale: CGFloat = 1 // self.layer?.contentsScale ?? 1
        let contextHeight = Int(bounds.height * scale)
        self.context.render(in: context, scale: scale, contextHeight: contextHeight)
    }
    
    public override var isFlipped: Bool {
        return true // 使坐标系从左上角开始（可选）
    }
    #endif
}


extension DebugView {
    public static func build(
        @DebugBuilder builder: () -> [any Debuggable]
    ) -> DebugView {
        let elements = builder().flatMap { $0.debugElements }
        return DebugView(elements: elements)
    }
}
