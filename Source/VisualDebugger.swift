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
    
    public func getDebugView(in coordinate:CoordinateSystem.Mode, visibleRect:CGRect? = nil, scale: CGFloat = 1.5, numDivisions:Int = 5, showOrigin:Bool = true) -> AppView {
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
    
    public func getDebugView(in coordinate:CoordinateSystem.Mode, visibleRect:CGRect? = nil, affineRect:AffineRect = .unit, image: AppImage? = nil, scale:CGFloat = 1.5, numDivisions:Int = 5, showOrigin:Bool = true, indexOrderRepresentation: IndexOrderRepresentation = .none) -> AppView {
        
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

//extension Array where Element == CGPoint {
//
//}
//
//extension Array : Debuggable where Element : Debuggable {
//
//    public var bounds: CGRect {
//        guard !self.isEmpty else { return .zero }
//        var rect = self[0].bounds
//        for i in 1 ..< self.count {
//            rect = self[i].bounds.union(rect)
//        }
//        return rect
//    }
//
//    public func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor) {
//
//    }
//}

// TODO: - Axis implements Debuggable also



























