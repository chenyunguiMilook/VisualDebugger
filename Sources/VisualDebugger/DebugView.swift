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
    public var elements: [any Debuggable] {
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
        coordinateSystem: CoordinateSystem2D = .yDown
    ) {
        let context = DebugContext(
            elements: elements,
            minWidth: minWidth,
            numSegments: numSegments,
            showOrigin: showOrigin,
            showCoordinate: showCoordinate,
            coordinateSystem: coordinateSystem
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
    
    public func append(_ element: Debuggable) {
        self.elements.append(element)
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

#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    //DebugView(debugRect: .init(x: -10, y: -20, width: 100, height: 200))
    DebugView(elements: [
        DebugPoints(points: [
            .init(x: 10, y: 10),
            .init(x: 10, y: 23),
            .init(x: 23, y: 67)
        ], color: .yellow)
        .overrideVertexStyle(at: 0, style: .shape(.rect, name: "start"))
        .overrideVertexStyle(at: 1, style: .label("A", name: "end"))
        
    ], coordinateSystem: .yDown)
}
