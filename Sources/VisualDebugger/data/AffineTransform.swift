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
    public var image: CGImage?
    public var transform: CGAffineTransform
    public var elements: [Debuggable] = []
    
    public init(rect: AffineRect, image: CGImage?, transform: CGAffineTransform) {
        self.rect = rect
        self.image = image
        self.transform = transform
        self.elements = getDebugElements()
    }
    
    private func getDebugElements() -> [Debuggable] {
        let rectFrom = self.rect
        let rectTo = self.rect * self.transform
        if let image = self.image {
            let start = AffineImage(image: image, rect: rectFrom, opacity: 0.4)
            let end = AffineImage(image: image, rect: rectTo, opacity: 0.8)
            return [start, end]
        } else {
            return [rectFrom, rectTo]
        }
    }
}

extension AffineTransform : Debuggable {
    
    public var bounds: CGRect {
        let result = elements[0].bounds
        return elements.reduce(result, { $0.union($1.bounds) })
    }
    
    public func debug(in coordinate: CoordinateSystem, color: AppColor?) {
        let color = color ?? coordinate.getNextColor()
        for element in self.elements {
            element.debug(in: coordinate, color: color)
        }
    }
}







