//  Debugger.swift
//
//  Copyright (c) 2017 ChenYunGui (陈云贵)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import CoreGraphics
import QuartzCore

// TODO: - documentation
// TODO: - draw sub grid

// MARK: - typealias

#if os(iOS) || os(tvOS)
    import UIKit
    public typealias AppBezierPath = UIBezierPath
    public typealias AppColor = UIColor
    public typealias AppFont = UIFont
    public typealias AppView = UIView
    public typealias AppImage = UIImage
#elseif os(macOS)
    import AppKit
    public typealias AppBezierPath = NSBezierPath
    public typealias AppColor = NSColor
    public typealias AppFont = NSFont
    public typealias AppView = NSView
    public typealias AppImage = NSImage
#endif


public extension Debuggable {
    
    public var debugView:AppView {
        return self.getDebugView(in: .yDown)
    }
    
    public func debugView(of options: DebugOptions = [], in visibleRect: CGRect? = nil) -> AppView {
        let config = DebugConfig(options: options)
        return getDebugView(in:            config.coordinate,
                            visibleRect:   visibleRect,
                            scale:         config.scale,
                            numDivisions:  config.numDivisions,
                            showOrigin:    config.showOrigin)
    }
    
    public func getDebugView(in coordinate:CoordinateSystemType, visibleRect:CGRect? = nil, scale: CGFloat = 1.5, numDivisions:Int = 5, showOrigin:Bool = true) -> AppView {
        let bounds = visibleRect ?? self.bounds.fixed()
        let layer = CoordinateSystem(type: coordinate, area: bounds, scale: scale, numSegments: numDivisions, showOrigin: showOrigin)
        layer.render(object: self)
        return debugLayer(layer, withMargin: layer.segmentLength)
    }
}

public extension Collection {
    
    public var debugView:AppView {
        return self.getDebugView(in: .yDown)
    }
    
    public func debugView(of options: DebugOptions = [], in visibleRect: CGRect? = nil, use affineRect: AffineRect = .unit, image: AppImage? = nil) -> AppView {
        let config = DebugConfig(options: options)
        return getDebugView(in:               config.coordinate,
                            visibleRect:      visibleRect,
                            affineRect:       affineRect,
                            image:            image,
                            scale:            config.scale,
                            numDivisions:     config.numDivisions,
                            showOrigin:       config.showOrigin,
                            indexOrderRepresentation: config.indexOrderRepresentation)
    }
    
    public func getDebugView(in coordinate:CoordinateSystemType, visibleRect:CGRect? = nil, affineRect:AffineRect = .unit, image: AppImage? = nil, scale:CGFloat = 1.5, numDivisions:Int = 5, showOrigin:Bool = true, indexOrderRepresentation: IndexOrderRepresentation = .none) -> AppView {
        
        func getPointsWrapper(points: [CGPoint], by indexOrderRepresentation: IndexOrderRepresentation) -> Debuggable {
            switch indexOrderRepresentation {
            case .none:       return PointsDotRepresenter(points:      points)
            case .gradient:   return PointsGradientRepresenter(points: points)
            case .indexLabel: return PointsLabelRepresenter(points:    points)
            }
        }
        
        // earlier check if is [CGPoint] or [CGAffineTransform]
        var debugObject: Debuggable?
        if let points = self as? [CGPoint] {
            debugObject = getPointsWrapper(points: points, by: indexOrderRepresentation)
        }
        else if let transforms = self as? [CGAffineTransform] {
            debugObject = AffineTransforms(rect: affineRect, image: image?.cgImage ?? getTransformImage(), transforms: transforms)
        }
        if debugObject != nil {
            return debugObject!.getDebugView(in: coordinate, visibleRect: visibleRect, scale: scale, numDivisions: numDivisions, showOrigin: showOrigin)
        }
        
        // 1. convert to Debuggable array
        var debugArray = [Debuggable]()
        for element in self {
            switch element {
            case let image as AppImage:
                debugArray.append(image.cgImage!)
            case let path as AppBezierPath:
                debugArray.append(path)
            case let debuggable as Debuggable:
                debugArray.append(debuggable)
            case let transfrom as CGAffineTransform:
                debugArray.append(AffineTransform(rect: affineRect, image: image?.cgImage ?? getTransformImage(), transform: transfrom))
            case let transforms as [CGAffineTransform]:
                debugArray.append(AffineTransforms(rect: affineRect, image: image?.cgImage ?? getTransformImage(), transforms: transforms))
            case let points as [CGPoint]:
                debugArray.append(getPointsWrapper(points: points, by: indexOrderRepresentation))
            default:
                break
            }
        }
        
        // 2. make sure debugArray not empty
        guard !debugArray.isEmpty else {
            return AppView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        
        // 3. calculate visible rect
        var bounds = visibleRect
        if bounds == nil {
            bounds = debugArray[0].bounds
            for i in 1 ..< debugArray.count {
                bounds = bounds!.union(debugArray[i].bounds)
            }
        }
        
        // 4. create coordinate layer and render objects
        guard let area = bounds?.fixed(), !area.isEmpty else { return AppView(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        let layer = CoordinateSystem(type: coordinate, area: area, scale: scale, numSegments: numDivisions, showOrigin: showOrigin)
        
        for object in debugArray {
            layer.render(object: object)
        }
        return debugLayer(layer, withMargin: layer.segmentLength)
    }
}



// MARK: - AppFont

extension AppFont {
    
    internal static var `default`:AppFont {
        return AppFont(name: ".HelveticaNeueInterface-Thin", size: 10) ?? AppFont.systemFont(ofSize: 10)
    }
}

// MARK: rendering work

func renderAxis(axis: AxisType, coordinate: CoordinateSystemType, labels: [AxisLabel], labelOffset: CGFloat, thickness: CGFloat, to layer: CALayer) {
    
    let path = AppBezierPath()
    let half = thickness/2
    let start = labels[0].position
    var vector = (labels[1].position - start)
    vector = vector.normalized(to: min(vector.length/2, thickness*3))
    let end = labels.last!.position + vector
    
    var labelOffsetX: CGFloat = 0
    var labelOffsetY: CGFloat = 0
    var lineOffsetX: CGFloat = 0
    var lineOffsetY: CGFloat = 0
    switch (axis, coordinate) {
    case (.x, .yUp):   labelOffsetY =  labelOffset; lineOffsetY =  half
    case (.x, .yDown): labelOffsetY = -labelOffset; lineOffsetY = -half
    case (.y, .yUp):   labelOffsetX = -labelOffset; lineOffsetX = -half
    case (.y, .yDown): labelOffsetX = -labelOffset; lineOffsetX = -half
    }
    
    // 1. draw main axis
    path.move(to: start)
    path.addLine(to: end)
    
    // 2. draw short lines
    for i in 0 ..< labels.count {
        let position = labels[i].position
        let lineEnd = CGPoint(x: position.x + lineOffsetX, y: position.y + lineOffsetY)
        path.move(to: position)
        path.addLine(to: lineEnd)
    }
    
    // 3. draw end arrow
    path.append(AxisArrow().pathAtEndOfSegment(segStart: start, segEnd: end))
    
    // 4. add bezier path layer
    let shapeLayer = CAShapeLayer()
    shapeLayer.lineWidth = 0.5
    shapeLayer.path = path.cgPath
    shapeLayer.strokeColor = AppColor.lightGray.cgColor
    shapeLayer.fillColor = nil
    shapeLayer.masksToBounds = false
    layer.addSublayer(shapeLayer)
    
    // 5. add labels layer
    for label in labels {
        let x = label.position.x + labelOffsetX
        let y = label.position.y + labelOffsetY
        let center = CGPoint(x: x, y: y)
        label.label.setCenter(center)
        layer.addSublayer(label.label)
    }
}

var transformImage: CGImage? = nil

func getTransformImage() -> CGImage {
    if transformImage == nil {
        transformImage = renderColorImage(width: 100, height: 100)
    }
    return transformImage!
}

public func renderColorImage(width: Int, height: Int, tl: AppColor = .red, tr: AppColor = .yellow, bl: AppColor = .blue, br: AppColor = .green) -> CGImage? {
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
    
    // flip the context
    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: 1, y: -1)
    
    for y in 0 ..< height {
        let ratio = CGFloat(y) / CGFloat(height)
        let startColor = interpolate(from: tl, to: bl, ratio: ratio)
        let endColor = interpolate(from: tr, to: br, ratio: ratio)
        let colors = [startColor.cgColor, endColor.cgColor] as CFArray
        var locations: [CGFloat] = [0, 1]
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: &locations) else { return nil }
        let startPoint = CGPoint(x: 0, y: CGFloat(y))
        let endPoint = CGPoint(x: width, y: y)
        context.saveGState() // *** Important: need call this, else will erase all context ***
        context.addRect(CGRect(x: 0, y: y, width: width, height: 1))
        context.clip()
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        context.restoreGState()
    }
    return context.makeImage()
}

// ========================================================================================================================
// ===========================================|       MARK: - Debuggable       |===========================================
// ========================================================================================================================

let kPointRadius: CGFloat = 3

extension CAShapeLayer {
    
    convenience init(path: CGPath, strokeColor: AppColor?, fillColor: AppColor?, lineWidth: CGFloat) {
        self.init()
        self.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        self.path = path
        self.strokeColor = strokeColor?.cgColor
        self.fillColor = fillColor?.cgColor
        self.lineWidth = lineWidth
        self.applyDefaultContentScale()
    }
}


// MARK: - PointsDotRepresenter

public struct PointsDotRepresenter {
    public var points: [CGPoint]
}

extension PointsDotRepresenter : Debuggable {
    
    public var bounds: CGRect {
        return self.points.bounds
    }
    
    public func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor) {
        let pnts = self.points * transform
        let path = AppBezierPath()
        for center in pnts {
            path.append(center.getBezierPath(radius: kPointRadius))
        }
        let shape = CAShapeLayer(path: path.cgPath, strokeColor: nil, fillColor: color, lineWidth: 0)
        layer.addSublayer(shape)
    }
}

// MARK: - PointsLabelRepresenter

public struct PointsLabelRepresenter {
    public var points: [CGPoint]
}

extension PointsLabelRepresenter : Debuggable {
    
    public var bounds: CGRect {
        return self.points.bounds
    }
    
    public func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor) {
        let pnts = self.points * transform
        for (i, point) in pnts.enumerated() {
            let textLayer = CATextLayer(indexLabel: "\(i)", color: color)
            textLayer.setCenter(point)
            textLayer.applyDefaultContentScale()
            layer.addSublayer(textLayer)
        }
    }
}

// MARK: - PointsGradientRepresenter

public struct PointsGradientRepresenter {
    public var points: [CGPoint]
}

extension PointsGradientRepresenter : Debuggable {
    
    public var bounds: CGRect {
        return self.points.bounds
    }
    
    public func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor) {
        let pnts = self.points * transform
        for (i, center) in pnts.enumerated() {
            let path: AppBezierPath
            if i == 0 || i == points.count-1 {
                let rect = CGRect(x: center.x-kPointRadius/2, y: center.y-kPointRadius/2, width: kPointRadius, height: kPointRadius)
                path = AppBezierPath(rect: rect)
            } else {
                path = center.getBezierPath(radius: kPointRadius)
            }
            let ratio = CGFloat(i)/CGFloat(points.count)
            let toColor = AppColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            let color = interpolate(from: .red, to: toColor, ratio: ratio)
            let shape = CAShapeLayer(path: path.cgPath, strokeColor: nil, fillColor: color, lineWidth: 0)
            layer.addSublayer(shape)
        }
    }
}

// MARK: - Point

extension CGPoint : Debuggable {
    
    public var bounds: CGRect {
        return CGRect(origin: self, size: .zero)
    }
    
    public func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor) {
        let newPoint = self * transform
        let path = newPoint.getBezierPath(radius: kPointRadius)
        let shapeLayer = CAShapeLayer(path: path.cgPath, strokeColor: nil, fillColor: color, lineWidth: 0)
        layer.addSublayer(shapeLayer)
    }
}

// MARK: - BezierPath

extension AppBezierPath : Debuggable {
    
    public func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor) {
        var mutableTransform = transform
        guard let cgPath = self.cgPath.copy(using: &mutableTransform) else { return }
        let shapeLayer = CAShapeLayer(path: cgPath, strokeColor: color, fillColor: nil, lineWidth: 1)
        layer.addSublayer(shapeLayer)
    }
}

// MARK: - AffineRect

extension AffineRect : Debuggable {
    
    public func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor) {
        let rect = self * transform
        let shape = AppBezierPath()
        shape.move(to: rect.v0)
        shape.addLine(to: rect.v1)
        shape.addLine(to: rect.v2)
        shape.addLine(to: rect.v3)
        shape.close()
        layer.addSublayer(CAShapeLayer(path: shape.cgPath, strokeColor: nil, fillColor: color.withAlphaComponent(0.2), lineWidth: 0))
        
        let xPath = AppBezierPath()
        xPath.move(to: rect.v0)
        xPath.addLine(to: rect.v1)
        layer.addSublayer(CAShapeLayer(path: xPath.cgPath, strokeColor: .red, fillColor: nil, lineWidth: 1))
        
        let yPath = AppBezierPath()
        yPath.move(to: rect.v0)
        yPath.addLine(to: rect.v3)
        layer.addSublayer(CAShapeLayer(path: yPath.cgPath, strokeColor: .green, fillColor: nil, lineWidth: 1))
    }
}



// MARK: - AffineTransforms

public struct AffineTransforms {
    
    public var rect: AffineRect
    public var image: CGImage
    public var transforms: [CGAffineTransform]
    internal var images: [AffineImage]!
    
    public init(rect: AffineRect, image: CGImage, transforms: [CGAffineTransform]) {
        self.rect = rect
        self.image = image
        self.transforms = transforms
        self.images = getImages()
    }
    
    private func getImages() -> [AffineImage] {
        let minAlpha: CGFloat = 0.4
        let maxAlpha: CGFloat = 0.8
        let alphaPading: CGFloat = (maxAlpha - minAlpha) / CGFloat(transforms.count)
        var lastRect = rect
        var lastAlpha = minAlpha
        var result = [AffineImage]()
        
        let image = AffineImage(image: self.image, rect: lastRect, opacity: lastAlpha)
        result.append(image)
        
        for transform in transforms {
            lastRect = lastRect * transform
            lastAlpha += alphaPading
            let image = AffineImage(image: self.image, rect: lastRect, opacity: lastAlpha)
            result.append(image)
        }
        return result
    }
}

extension AffineTransforms : Debuggable {
    
    public var bounds: CGRect {
        let result = images[0].bounds
        return images.reduce(result, { $0.union($1.bounds) })
    }
    
    public func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor) {
        for image in self.images {
            image.debug(in: layer, with: transform, color: color)
        }
    }
}

func clockwiseInYDown(v0: CGPoint, v1: CGPoint, v2: CGPoint) -> Bool {
    return (v2.x - v0.x) * (v1.y - v2.y) < (v2.y - v0.y) * (v1.x - v2.x)
}

// MARK: - CGImage

extension CGImage : Debuggable {
    
    public var bounds: CGRect {
        let size = CGSize(width: width, height: height)
        return CGRect(origin: .zero, size: size)
    }
    
    public func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor) {
        let affineRect = self.bounds.affineRect
        let affineImage = AffineImage(image: self, rect: affineRect, opacity: 1)
        affineImage.debug(in: layer, with: transform, color: color)
    }
}

extension Array where Element == CGPoint {
    
}

extension Array : Debuggable where Element : Debuggable {
    
    public var bounds: CGRect {
        guard !self.isEmpty else { return .zero }
        var rect = self[0].bounds
        for i in 1 ..< self.count {
            rect = self[i].bounds.union(rect)
        }
        return rect
    }
    
    public func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor) {
        
    }
}

// TODO: - Axis implements Debuggable also



























