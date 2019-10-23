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

extension Debuggable {
    public var debugView: AppView {
        return self.getDebugView(in: .yDown)
    }

    public func getDebugView(in coordinate: CoordinateSystem.Kind,
                             color: AppColor? = nil,
                             visibleRect: CGRect? = nil,
                             scale: CGFloat = 1.5,
                             numDivisions: Int = 5,
                             showOrigin: Bool = true) -> AppView {
        let bounds = visibleRect ?? self.bounds.fixed()
        let coordinate = CoordinateSystem(type: coordinate,
                                          area: bounds,
                                          scale: scale,
                                          numSegments: numDivisions,
                                          showOrigin: showOrigin)
        self.debug(in: coordinate, color: color)
        return debugLayer(coordinate, withMargin: coordinate.segmentLength)
    }
}

extension Array: Debuggable where Element: Debuggable {
    public var bounds: CGRect {
        return self.map { $0.bounds }.bounds
    }

    public func debug(in coordinate: CoordinateSystem, color: AppColor?) {
        let color = color ?? coordinate.getNextColor()
        for element in self {
            element.debug(in: coordinate, color: color)
        }
    }
}

public func debug(_ array: [Debuggable],
                  colors: [AppColor]? = nil,
                  coordinate: CoordinateSystem.Kind = .yDown,
                  visibleRect: CGRect? = nil,
                  scale: CGFloat = 1.5,
                  numDivisions: Int = 5,
                  showOrigin: Bool = true) -> AppView {
    let bounds = visibleRect ?? (array.map { $0.bounds }.bounds)
    let coordinate = CoordinateSystem(type: coordinate,
                                      area: bounds,
                                      scale: scale,
                                      numSegments: numDivisions,
                                      showOrigin: showOrigin)
    
    for (i, element) in array.enumerated() {
        let color: AppColor? = (colors != nil && i < colors!.count) ? colors![i] : nil
        element.debug(in: coordinate, color: color)
    }
    return debugLayer(coordinate, withMargin: coordinate.segmentLength)
}

