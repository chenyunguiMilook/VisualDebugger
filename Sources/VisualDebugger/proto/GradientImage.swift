//
//  GradientImage.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics

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
