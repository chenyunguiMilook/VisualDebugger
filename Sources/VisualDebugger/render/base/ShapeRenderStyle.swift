//
//  ShapeRenderStyle.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


import Foundation
import CoreGraphics
import SwiftUI
import VisualUtils

public protocol RenderableShape {
    var path: AppBezierPath { get }
}

public struct ShapeRenderStyle: Sendable {
    public struct Stroke: Sendable {
        public var color: AppColor
        public var style: StrokeStyle
        
        public init(color: AppColor, style: StrokeStyle) {
            self.color = color
            self.style = style
        }
    }
    public struct Fill: Sendable {
        public var color: AppColor
        public var style: FillStyle
        
        public init(color: AppColor, style: FillStyle = FillStyle()) {
            self.color = color
            self.style = style
        }
    }
    
    public var stroke: Stroke?
    public var fill: Fill?
    public var isEmpty: Bool {
        stroke == nil && fill == nil
    }
    
    public init(stroke: Stroke? = nil, fill: Fill? = nil) {
        self.stroke = stroke
        self.fill = fill
    }
}

extension ShapeRenderStyle.Stroke {
    public func set(for context: CGContext) {
        context.setStrokeColor(self.color.cgColor)
        context.setLineWidth(self.style.lineWidth)
        context.setLineCap(self.style.lineCap)
        context.setLineJoin(self.style.lineJoin)
        context.setMiterLimit(self.style.miterLimit)
        if !style.dash.isEmpty {
            context.setLineDash(phase: style.dashPhase, lengths: style.dash)
        }
    }
}

extension ShapeRenderStyle.Fill {
    public var rule: CGPathFillRule {
        style.isEOFilled ? .evenOdd : .winding
    }
    public func set(for context: CGContext) {
        context.setFillColor(self.color.cgColor)
    }
}

extension CGContext {

    public func render<S>(shape: S, style: ShapeRenderStyle) where S: RenderableShape {
        let cgPath = shape.path.cgPath
        self.render(path: cgPath, style: style)
    }
    
    public func render(path cgPath: CGPath, style: ShapeRenderStyle) {
        guard !cgPath.isEmpty, !style.isEmpty else { return }
        self.saveGState()
        defer { self.restoreGState() }
        // fill
        if let fill = style.fill {
            self.addPath(cgPath)
            fill.set(for: self)
            self.fillPath(using: fill.rule)
        }
        
        // stroke
        if let stroke = style.stroke {
            self.addPath(cgPath)
            stroke.set(for: self)
            self.strokePath()
        }
    }
    
    public func renderCircle(center: CGPoint, radius: Double, style: ShapeRenderStyle) {
        let rect = CGRect(center: center, size: .init(width: radius * 2, height: radius * 2))
        let path = AppBezierPath(ovalIn: rect)
        self.render(path: path.cgPath, style: style)
    }

    public func renderRect(_ rect: CGRect, style: ShapeRenderStyle) {
        let path = AppBezierPath(rect: rect)
        self.render(path: path.cgPath, style: style)
    }
}
