//
//  TextRenderStyle.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import Foundation
import CoreGraphics
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import VisualUtils

public typealias Anchor = VisualUtils.Anchor

public struct TextRenderStyle: @unchecked Sendable {
    public struct Stroke: Sendable {
        public var color: AppColor
        public var width: Double // this is value is percentage relative to font size, normally set to 30
        
        public init(color: AppColor, width: Double) {
            self.color = color
            self.width = width
        }
    }
    
    public let font: AppFont
    /// text insets, if bgColor not nil, will fill insets rect
    public var insets: AppEdgeInsets
    /// outer insets, control spacing
    public var margin: AppEdgeInsets
    public var anchor: Anchor
    public var textStroke: Stroke?
    public var textColor: AppColor
    public var textShadow: Shadow?
    public var bgStyle: BgStyle?
    
    public var strokeAttribute: [NSAttributedString.Key: Any]? {
        guard let textStroke else { return nil }
        var attr = [NSAttributedString.Key: Any]()
        attr[.font] = font
        attr[.strokeColor] = textStroke.color
        attr[.strokeWidth] = textStroke.width
        attr[.foregroundColor] = AppColor.clear
        return attr
    }
    
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
        textStroke: Stroke? = nil,
        textColor: AppColor,
        textShadow: Shadow? = nil,
        bgStyle: BgStyle? = nil
    ) {
        self.font = font
        self.insets = insets
        self.margin = margin
        self.anchor = anchor
        self.textStroke = textStroke
        self.textColor = textColor
        self.textShadow = textShadow
        self.bgStyle = bgStyle
    }
    
    public mutating func setTextLocation(_ location: TextLocation) {
        self.anchor = location.anchor
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
        scale: CGFloat = 1,
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
        self.fixCTM(scaleFactor: scale, contextHeight: _contextHeight)
        self.concatenate((flipVertically * anchorToZeroM * transform))
        self.setAlpha(alpha)
        
        UIGraphicsPushContext(self)
        if let bgStyle = style.bgStyle {
            renderBg(bgStyle: bgStyle, bgBounds: bgBounds)
        }
        if let shadow = style.textShadow {
            self.setShadow(offset: shadow.offset, blur: shadow.blur, color: shadow.color.cgColor)
        }
        
        if let stroke = style.strokeAttribute {
            let str = NSAttributedString(string: text, attributes: stroke)
            str.draw(at: .zero)
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
        scale: CGFloat = 1,
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
        
        if let shadow = style.textShadow {
            self.setShadow(offset: shadow.offset, blur: shadow.blur, color: shadow.color.cgColor)
        }
        
        if let stroke = style.strokeAttribute {
            let str = NSAttributedString(string: text, attributes: stroke)
            str.draw(at: .zero)
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
