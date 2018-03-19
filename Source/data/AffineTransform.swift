//
//  AffineTransform.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#else
import Cocoa
#endif

public struct AffineTransform {
    
    public var rect: AffineRect
    public var image: CGImage
    public var transform: CGAffineTransform
    internal var images: [AffineImage]!
    
    public init(rect: AffineRect, image: CGImage, transform: CGAffineTransform) {
        self.rect = rect
        self.image = image
        self.transform = transform
        self.images = getImages()
    }
    
    private func getImages() -> [AffineImage] {
        let start = AffineImage(image: self.image, rect: self.rect, opacity: 0.4)
        let end = AffineImage(image: self.image, rect: self.rect * self.transform, opacity: 0.8)
        return [start, end]
    }
}

extension AffineTransform : Debuggable {
    
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
