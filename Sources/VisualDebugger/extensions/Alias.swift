//
//  Alias.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


#if canImport(UIKit)
    import UIKit
    public typealias AppBezierPath = UIBezierPath
    public typealias AppPasteboard = UIPasteboard
    public typealias AppScreen = UIScreen
    public typealias AppColor = UIColor
    public typealias AppImage = UIImage
    public typealias AppFont = UIFont
    public typealias AppEdgeInsets = UIEdgeInsets
    public typealias AppKeyModifierFlags = UIKeyModifierFlags
    public typealias AppEvent = UIEvent
    public typealias AppView = UIView

#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    public typealias AppBezierPath = NSBezierPath
    public typealias AppPasteboard = NSPasteboard
    public typealias AppScreen = NSScreen
    public typealias AppColor = NSColor
    public typealias AppImage = NSImage
    public typealias AppFont = NSFont
    public typealias AppEdgeInsets = NSEdgeInsets
    public typealias AppKeyModifierFlags = NSEvent.ModifierFlags
    public typealias AppEvent = NSEvent
    public typealias AppView = NSView

extension NSEdgeInsets {
    static let zero = NSEdgeInsets()
}

extension NSFont {
    static func italicSystemFont(ofSize size: CGFloat) -> NSFont {
        let baseFont = NSFont.systemFont(ofSize: size)
        let italicDescriptor = baseFont.fontDescriptor.withSymbolicTraits(.italic)
        // Create the italic font using the descriptor
        return NSFont(descriptor: italicDescriptor, size: size) ?? baseFont
    }
}

extension NSBezierPath {
    
    convenience init(cgPath: CGPath) {
        self.init()
        cgPath.applyWithBlock { pointer in
            let element = pointer.pointee
            let points = element.points
            switch element.type {
            case .moveToPoint:
                self.move(to: points[0])
            case .addLineToPoint:
                self.line(to: points[0])
            case .addQuadCurveToPoint:
                addQuadCurve(to: points[1], controlPoint: points[0])
            case .addCurveToPoint:
                curve(to: points[2], controlPoint1: points[0], controlPoint2: points[1])
            case .closeSubpath:
                close()
            default: break
            }
        }
    }
    
    convenience init(roundedRect: CGRect, cornerRadius: CGFloat) {
        self.init(roundedRect: roundedRect, xRadius: cornerRadius, yRadius: cornerRadius)
    }

    func apply(_ t: CGAffineTransform) {
        let transform = AffineTransform(
            m11: t.a,
            m12: t.b,
            m21: t.c,
            m22: t.d,
            tX: t.tx,
            tY: t.ty
        )
        self.transform(using: transform)
    }

    func reversing() -> NSBezierPath {
        return self.reversed
    }

    func addLine(to point: CGPoint) {
        self.line(to: point)
    }

    func addCurve(
        to point: CGPoint,
        controlPoint1 point1: CGPoint,
        controlPoint2 point2: CGPoint
    ) {
        self.curve(to: point, controlPoint1: point1, controlPoint2: point2)
    }

    private func interpolate(_ p1: CGPoint, _ p2: CGPoint, _ ratio: CGFloat) -> CGPoint {
        return CGPoint(x: p1.x + (p2.x - p1.x) * ratio, y: p1.y + (p2.y - p1.y) * ratio)
    }

    func addQuadCurve(to end: CGPoint, controlPoint: CGPoint) {
        let start = self.currentPoint
        let control1 = self.interpolate(start, controlPoint, 0.666666)
        let control2 = self.interpolate(end, controlPoint, 0.666666)
        self.curve(to: end, controlPoint1: control1, controlPoint2: control2)
    }

    func addArc(
        withCenter center: CGPoint,
        radius: CGFloat,
        startAngle: CGFloat,
        endAngle: CGFloat,
        clockwise: Bool
    ) {
        self.appendArc(
            withCenter: center,
            radius: radius,
            startAngle: startAngle * 180 / .pi,
            endAngle: endAngle * 180 / .pi,
            clockwise: !clockwise
        )
    }
}
#endif

import CoreGraphics
public typealias Matrix2D = CGAffineTransform

