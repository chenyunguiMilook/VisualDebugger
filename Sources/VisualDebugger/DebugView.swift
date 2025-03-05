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
    
    public var showCoordinate: Bool {
        get { context.showCoordinate }
        set {
            context.showCoordinate = newValue
            self.refresh()
        }
    }
    public var coordinateSystem: CoordinateSystem2D {
        get { context.coordinateSystem }
        set {
            context.coordinateSystem = newValue
            self.refresh()
        }
    }
    public var elements: [any ContextRenderable] {
        get { context.elements }
        set {
            context.elements = newValue
            self.refresh()
        }
    }
    
    public init(
        elements: [any Debuggable],
        minWidth: Double = 250,
        numSegments: Int = 5,
        showOrigin: Bool = false,
        showCoordinate: Bool = true,
        coordinateSystem: CoordinateSystem2D = .yDown,
        coordinateStyle: CoordinateStyle = .default
    ) {
        let context = DebugContext(
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
