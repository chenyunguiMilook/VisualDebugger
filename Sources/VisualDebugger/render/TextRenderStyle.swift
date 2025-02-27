//
//  TextRenderStyle.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import Foundation
import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct TextRenderStyle: @unchecked Sendable {
    
    public let font: AppFont
    /// text insets, if bgColor not nil, will fill insets rect
    public var insets: AppEdgeInsets
    /// outer insets, control spacing
    public var margin: AppEdgeInsets
    public var anchor: Anchor
    public var textColor: AppColor
    public var bgStyle: BgStyle?
    
    public var attributes: [NSAttributedString.Key: Any] {
        var attr = [NSAttributedString.Key: Any]()
        attr[.font] = font
        attr[.foregroundColor] = textColor
        return attr
    }
    
    public init(
        font: AppFont,
        insets: AppEdgeInsets,
        margin: AppEdgeInsets,
        anchor: Anchor,
        textColor: AppColor,
        bgStyle: BgStyle? = nil
    ) {
        self.font = font
        self.insets = insets
        self.margin = margin
        self.anchor = anchor
        self.textColor = textColor
        self.bgStyle = bgStyle
    }
    
    public func getTextSize(text: String) -> CGSize {
        let size = CGSize(width: Double.infinity, height: Double.infinity)
        let bounds = text.boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
        return CGSize(
            width: bounds.size.width.rounded(.up),
            height: bounds.size.height.rounded(.up)
        )
    }
}

extension CGContext {
    
    /// - Parameters:
    ///   - text: text value to draw
    ///   - transform: text transform
    ///   - style: text style data
    ///   - alpha: opacity
    ///   - contentScaleFactor: render scale
    ///   - contextHeight: important: this value need multiply the scale value
    ///   - flipText: whether flip text
    #if os(iOS)
    public func render(
        text: String,
        transform: CGAffineTransform,
        style: TextRenderStyle,
        alpha: Double = 1,
        contentScaleFactor: CGFloat = 1,
        contextHeight: Int? = nil,
        flipText: Bool = false
    ) {
        guard !text.isEmpty else { return }
        let attributeString = NSAttributedString(string: text, attributes: style.attributes)
        let textSize = style.getTextSize(text: text)
        
        let textBounds = CGRect(origin: .zero, size: textSize)
        let bgBounds = textBounds.expanding(by: style.insets)
        let bounds = bgBounds.expanding(by: style.margin)
        
        self.saveGState()
        defer { self.restoreGState() }
        
        let anchorToZeroM = Matrix2D(translation: -bounds.getAnchor(style.anchor))
        let flipVertically = flipText ? Matrix2D(scaleX: 1, scaleY: -1, aroundCenter: bounds.center) : .identity
        let _contextHeight = CGFloat(contextHeight ?? self.height)
        self.fixCTM(scaleFactor: contentScaleFactor, contextHeight: _contextHeight)
        self.concatenate((flipVertically * anchorToZeroM * transform))
        self.setAlpha(alpha)
        
        UIGraphicsPushContext(self)
        if let bgStyle = style.bgStyle {
            renderBg(bgStyle: bgStyle, bgBounds: bgBounds)
        }
        attributeString.draw(at: .zero)
        UIGraphicsPopContext()
    }
    
    #elseif os(macOS)
    public func render(
        text: String,
        transform: CGAffineTransform,
        style: TextRenderStyle,
        alpha: Double = 1,
        contentScaleFactor: CGFloat = 1,
        contextHeight: Int? = nil
    ) {
        guard !text.isEmpty else { return }
        let attributeString = NSAttributedString(string: text, attributes: style.attributes)
        let textSize = style.getTextSize(text: text)
        
        let textBounds = CGRect(origin: .zero, size: textSize)
        let bgBounds = textBounds.expanding(by: style.insets)
        let bounds = bgBounds.expanding(by: style.margin)
        
        self.saveGState()
        defer { self.restoreGState() }
        
        let anchorToZeroM = Matrix2D(translation: -bounds.getAnchor(style.anchor))
        self.concatenate(anchorToZeroM * transform)
        self.setAlpha(alpha)
        
        let prevContext = NSGraphicsContext.current
        let gContext = NSGraphicsContext(cgContext: self, flipped: true)
        NSGraphicsContext.current = gContext
        
        if let bgStyle = style.bgStyle {
            renderBg(bgStyle: bgStyle, bgBounds: bgBounds)
        }
        attributeString.draw(at: .zero)
        NSGraphicsContext.current = prevContext
    }
    #endif
    
    private func renderBg(bgStyle: TextRenderStyle.BgStyle, bgBounds: CGRect) {
        let path: AppBezierPath
        switch bgStyle {
        case .rect:
            path = AppBezierPath(rect: bgBounds)
        case .roundRect(radius: let radius, _, _):
            var rect = bgBounds
            if bgBounds.width < radius * 2 {
                rect = CGRect.init(
                    center: bgBounds.center,
                    size: .init(
                        width: radius * 2,
                        height: bgBounds.height
                    )
                )
            }
            path = AppBezierPath(roundedRect: rect, cornerRadius: radius)
        case .capsule:
            var rect = bgBounds
            if bgBounds.width < bgBounds.height {
                rect = CGRect(
                    center: bgBounds.center,
                    size: .init(
                        width: bgBounds.height,
                        height: bgBounds.height
                    )
                )
            }
            path = AppBezierPath(roundedRect: rect, cornerRadius: rect.height/2)
        }
        self.addPath(path.cgPath)
        if bgStyle.filled {
            self.setFillColor(bgStyle.color.cgColor)
            self.fillPath()
        } else {
            self.setStrokeColor(bgStyle.color.cgColor)
            self.setLineWidth(1)
            self.strokePath()
        }
    }
    
    public func fixCTM(scaleFactor: CGFloat, contextHeight: CGFloat) {
        // toYDownMatrix = scaleMatrix * moveMatrix
        let toYDownCoord = CGAffineTransform(
            a: scaleFactor,
            b: 0,
            c: 0,
            d: -scaleFactor,
            tx: 0,
            ty: contextHeight
        )
        if !self.ctm.isIdentity {
            self.concatenate(self.ctm.inverted())
        }
        self.concatenate(toYDownCoord)
    }
}
