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
    
    public func getDebugView(in coordinate:CoordinateSystem.Kind, visibleRect:CGRect? = nil, scale: CGFloat = 1.5, numDivisions:Int = 5, showOrigin:Bool = true) -> AppView {
        let bounds = visibleRect ?? self.bounds.fixed()
        let layer = CoordinateSystem(type: coordinate, area: bounds, scale: scale, numSegments: numDivisions, showOrigin: showOrigin)
        layer.render(object: self)
        return debugLayer(layer, withMargin: layer.segmentLength)
    }
}

//public extension Collection {
//
//    public var debugView:AppView {
//        return self.getDebugView(in: .yDown)
//    }
//
//    public func debugView(of options: DebugOptions = [], in visibleRect: CGRect? = nil, use affineRect: AffineRect = .unit, image: AppImage? = nil) -> AppView {
//        let config = DebugConfig(options: options)
//        return getDebugView(in:               config.coordinate,
//                            visibleRect:      visibleRect,
//                            affineRect:       affineRect,
//                            image:            image,
//                            scale:            config.scale,
//                            numDivisions:     config.numDivisions,
//                            showOrigin:       config.showOrigin)
//    }
//
//    public func getDebugView(in coordinate:CoordinateSystem.Kind, visibleRect:CGRect? = nil, affineRect:AffineRect = .unit, image: AppImage? = nil, scale:CGFloat = 1.5, numDivisions:Int = 5, showOrigin:Bool = true) -> AppView {
//
//        // earlier check if is [CGPoint] or [CGAffineTransform]
//        var debugObject: Debuggable?
//        if let transforms = self as? [CGAffineTransform] {
//            debugObject = AffineTransforms(rect: affineRect, image: image?.cgImage ?? getTransformImage(), transforms: transforms)
//        }
//        if debugObject != nil {
//            return debugObject!.getDebugView(in: coordinate, visibleRect: visibleRect, scale: scale, numDivisions: numDivisions, showOrigin: showOrigin)
//        }
//
//        // 1. convert to Debuggable array
//        var debugArray = [Debuggable]()
//        for element in self {
//            switch element {
//            case let image as AppImage:
//                debugArray.append(image.cgImage!)
//            case let path as AppBezierPath:
//                debugArray.append(path)
//            case let debuggable as Debuggable:
//                debugArray.append(debuggable)
//            case let transfrom as CGAffineTransform:
//                debugArray.append(AffineTransform(rect: affineRect, image: image?.cgImage ?? getTransformImage(), transform: transfrom))
//            case let transforms as [CGAffineTransform]:
//                debugArray.append(AffineTransforms(rect: affineRect, image: image?.cgImage ?? getTransformImage(), transforms: transforms))
//            case let points as [CGPoint]:
//                debugArray.append(getPointsWrapper(points: points, by: indexOrderRepresentation))
//            default:
//                break
//            }
//        }
//
//        // 2. make sure debugArray not empty
//        guard !debugArray.isEmpty else {
//            return AppView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
//        }
//
//        // 3. calculate visible rect
//        var bounds = visibleRect
//        if bounds == nil {
//            bounds = debugArray[0].bounds
//            for i in 1 ..< debugArray.count {
//                bounds = bounds!.union(debugArray[i].bounds)
//            }
//        }
//
//        // 4. create coordinate layer and render objects
//        guard let area = bounds?.fixed(), !area.isEmpty else { return AppView(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
//        let layer = CoordinateSystem(type: coordinate, area: area, scale: scale, numSegments: numDivisions, showOrigin: showOrigin)
//
//        for object in debugArray {
//            layer.render(object: object)
//        }
//        return debugLayer(layer, withMargin: layer.segmentLength)
//    }
//}



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




// MARK: - BezierPath

extension AppBezierPath : Debuggable {
    
    public func debug(in coordinate: CoordinateSystem) {
        var mutableTransform = coordinate.matrix
        guard let cgPath = self.cgPath.copy(using: &mutableTransform) else { return }
        let shapeLayer = CAShapeLayer(path: cgPath, strokeColor: coordinate.getNextColor(), fillColor: nil, lineWidth: 1)
        coordinate.addSublayer(shapeLayer)
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


























