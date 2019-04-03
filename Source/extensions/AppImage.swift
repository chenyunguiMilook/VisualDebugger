//
//  CGImage+Behavior.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/20.
//

import Foundation
import CoreGraphics

// MARK: - CGImage

extension CGImage : Debuggable {
    
    public var bounds: CGRect {
        let size = CGSize(width: width, height: height)
        return CGRect(origin: .zero, size: size)
    }
    
    public func debug(in coordinate: CoordinateSystem, color: AppColor?) {
        let affineRect = self.bounds.affineRect
        let affineImage = AffineImage(image: self, rect: affineRect, opacity: 1)
        affineImage.debug(in: coordinate, color: color)
    }
}

#if os(macOS)
import AppKit

extension NSImage {
    
    public var cgImage: CGImage? {
        return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
}
#endif
