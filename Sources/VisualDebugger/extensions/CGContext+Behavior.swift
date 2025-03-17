//
//  CGContext+Behavior.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import CoreGraphics

func withImageContext(
    width w: CGFloat,
    height h: CGFloat,
    scale: CGFloat = 1,
    bgColor: CGColor? = nil,
    useDeviceSpace: Bool = true,
    colorSpace: CGColorSpace? = nil,
    byteOrderInfo: CGImageByteOrderInfo = .orderDefault,
    alphaInfo: CGImageAlphaInfo = .premultipliedLast,
    _ handler: (CGContext) throws -> Void
) rethrows -> CGImage? {
    let width = Int(w * scale)
    let height = Int(h * scale)
    let rect = CGRect(x: 0, y: 0, width: width, height: height)

    let pixels = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
    defer { pixels.deallocate() }

    var _colorSpace = colorSpace
    if _colorSpace == nil {
        if alphaInfo == .alphaOnly {
            _colorSpace = CGColorSpaceCreateDeviceGray()
        } else {
            _colorSpace = CGColorSpaceCreateDeviceRGB()
        }
    }
    let bitmapInfo = CGBitmapInfo(rawValue: byteOrderInfo.rawValue | alphaInfo.rawValue)

    guard
        let context = CGContext(
            data: pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: _colorSpace!,
            bitmapInfo: bitmapInfo.rawValue
        )
    else {
        return nil
    }

    context.clear(rect)

    if let bgColor = bgColor {
        context.saveGState()
        context.setFillColor(bgColor)
        context.fill(rect)
        context.restoreGState()
    }

    context.interpolationQuality = .high
    context.setShouldSmoothFonts(true)
    if useDeviceSpace {
        context.concatenate(context.userSpaceToDeviceSpaceTransform)
    }
    context.concatenate(CGAffineTransform(scaleX: scale, y: scale))
    
    try handler(context)
    return context.makeImage()
}
