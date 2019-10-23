//
//  AffineImage.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics
#if os(iOS) || os(tvOS)
import UIKit
#else
import Cocoa
#endif

public struct AffineImage {
    
    public var image: CGImage
    public var rect: AffineRect
    public var opacity: CGFloat
}

extension AffineImage : Debuggable {
    
    public var bounds: CGRect {
        return rect.bounds
    }
    
    public func debug(in coordinate: CoordinateSystem, color: AppColor?) {
        let target = self.rect * coordinate.matrix
        let targetCenter = target.center
        
        let clockwise = clockwiseInYDown(v0: target.v3, v1: target.v0, v2: target.v1)
        let scaleOffset: CGFloat = clockwise ? 1 : -1
        
        let imageSize = CGSize(width: image.width, height: image.height)
        let imageRect = CGRect(origin: .zero, size: imageSize)
        let imageCenter = CGPoint(x: imageRect.midX, y: imageRect.midY)
        
        let scale = CGAffineTransform(scaleX: target.width/imageSize.width, y: (target.height/imageSize.height) * scaleOffset)
        let rotate = CGAffineTransform(rotationAngle: target.angle)
        let translate = CGAffineTransform(translationX: targetCenter.x - imageCenter.x, y: targetCenter.y - imageCenter.y)
        
        let imageLayer = CALayer()
        imageLayer.contents = image
        imageLayer.frame = imageRect
        imageLayer.opacity = Float(opacity)
        imageLayer.setAffineTransform(scale * rotate * translate)
        imageLayer.applyDefaultContentScale()
        
        coordinate.addSublayer(imageLayer)
    }
}
