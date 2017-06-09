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

// MARK: - enums

public enum CoordinateSystemType {
    case yDown, yUp
}

public enum AxisType {
    case x, y
}

/// Data structure to hold all necessary infomation for axis

public struct AxisData {
    
    // start value of the axis
    public var startValue:CGFloat
    // length value of the axis
    public var lengthValue: CGFloat
    // the value of each segment
    public var segmentValue:CGFloat
    // number segments of starting (reach to 0)
    public var startSegments:Int
    // total segments
    public var numSegments:Int
    
    /// the origin value in the coordinate system
    public var originValue: CGFloat {
        return self.startValue + self.segmentValue * CGFloat(self.startSegments)
    }
    
    /// end value of the axis
    public var endValue: CGFloat {
        return self.startValue + self.lengthValue
    }
    
    public init(min minValue:CGFloat, max maxValue:CGFloat, segmentValue:CGFloat) {
        self.startValue = floor(minValue / segmentValue) * segmentValue
        self.segmentValue = segmentValue
        self.startSegments = Int(ceil(abs(startValue) / segmentValue))
        self.numSegments = Int(ceil((maxValue-startValue) / segmentValue))
        self.lengthValue = segmentValue * CGFloat(numSegments)
    }
}

public class CoordinateSystem : CALayer {
    
    public let minWidth: CGFloat = 250
    
    public var type:CoordinateSystemType
    public var area:CGRect
    public var segmentLength:CGFloat = 50
    public var scale: CGFloat = 1.5
    public var numSegments:Int
    public var showOrigin:Bool
    
    // for transform values to current coordinate system space
    public internal(set) var matrix = CGAffineTransform.identity
    
    internal var colorIndex:Int = 0
    internal var minSegmentLength: CGFloat {
        return minWidth / CGFloat(numSegments)
    }
    
    public init(type: CoordinateSystemType, area:CGRect, scale:CGFloat, numSegments:Int, showOrigin:Bool, precision:Int = 5) {
        self.type = type
        self.area = area
        self.scale =  scale
        self.numSegments = numSegments
        self.showOrigin = showOrigin
        super.init()
        
        let rect = showOrigin ? self.getRectFromOrigin(by: area) : area
        let maxValue = max(rect.size.width, rect.size.height)
        let segmentValue = CGFloat(getDivision(Double(maxValue), segments: numSegments))
        
        let xAxisData = AxisData(min: rect.minX, max: rect.maxX, segmentValue: segmentValue)
        let yAxisData = AxisData(min: rect.minY, max: rect.maxY, segmentValue: segmentValue)
        
        let valueRect = CGRect(x: xAxisData.startValue, y: yAxisData.startValue, width: xAxisData.lengthValue, height: yAxisData.lengthValue)
        let xAxisY: CGFloat = (valueRect.minY < 0 && valueRect.maxY >= 0) ? 0 : yAxisData.startValue
        let yAxisX: CGFloat = (valueRect.minX < 0 && valueRect.maxX >= 0) ? 0 : xAxisData.startValue
        
        // calculate axis segments in value space
        let xAxisSegment = AxisSegment(start: CGPoint(x: xAxisData.startValue, y: xAxisY), end: CGPoint(x: xAxisData.endValue, y: xAxisY))
        let yAxisSegment = AxisSegment(start: CGPoint(x: yAxisX, y: yAxisData.startValue), end: CGPoint(x: yAxisX, y: yAxisData.endValue))
        
        // get axis labels and transform to render space
        let precision = calculatePrecision(Double(segmentValue))
        let formater = NumberFormatter(precision: precision)
        var xAxisLabels = xAxisSegment.getLabels(axis: .x, segmentValue: segmentValue, numSegments: xAxisData.numSegments, numFormater: formater)
        var yAxisLabels = yAxisSegment.getLabels(axis: .y, segmentValue: segmentValue, numSegments: yAxisData.numSegments, numFormater: formater)
        
        // calculate the proper segment length
        let xLabelBounds = xAxisLabels.reduce(CGRect.zero) { $0.union($1.label.bounds) }
        self.segmentLength = xLabelBounds.width < minSegmentLength ? minSegmentLength : xLabelBounds.width
        self.segmentLength = ceil(segmentLength * scale)
        
        // calculate the matrix for transform value from value space to render space
        let scale = self.segmentLength / segmentValue
        self.matrix = CGAffineTransform(translationX: -valueRect.origin.x, y: -valueRect.origin.y)
        self.matrix.scaleBy(x: scale, y: scale)
        
        if self.type == .yUp {
            let renderHeight = valueRect.height * scale
            self.matrix.scaleBy(x: 1, y: -1)
            self.matrix.translateBy(x: 0, y: renderHeight)
        }
        
        // get axis labels and transform to render space
        xAxisLabels = xAxisLabels * self.matrix
        yAxisLabels = yAxisLabels * self.matrix
        
        // render axis to self
        let thickness: CGFloat = 8
        renderAxis(axis: .x, coordinate: self.type, labels: xAxisLabels, labelOffset: ceil(xLabelBounds.height), thickness: thickness, to: self)
        renderAxis(axis: .y, coordinate: self.type, labels: yAxisLabels, labelOffset: ceil(xLabelBounds.width/2) + thickness, thickness: thickness, to: self)
        
        // setup frame
        self.frame = valueRect.applying(self.matrix)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getRectFromOrigin(by bounds:CGRect) -> CGRect {
        let minX = min(0, bounds.minX)
        let minY = min(0, bounds.minY)
        let maxX = max(0, bounds.maxX)
        let maxY = max(0, bounds.maxY)
        return CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
    }
    
    public func getNextColor() -> AppColor {
        let color = AppColor.get(self.colorIndex % colors.count)
        self.colorIndex += 1
        return color
    }
    
    public func render(object: Debuggable, color: AppColor? = nil) {
        object.debug(in: self, with: self.matrix, color: color ?? getNextColor())
    }
}

// MARK: - Debugger view


#if os(macOS)
    internal class FlippedView : AppView {
        override var isFlipped: Bool { return true }
    }
#endif

public func debugLayer(_ layer:CALayer, withMargin margin:CGFloat) -> AppView {
    
    layer.frame.origin.x += margin
    layer.frame.origin.y += margin
    
    let width = layer.bounds.width + margin * 2
    let height = layer.bounds.height + margin * 2
    let frame = CGRect(x: 0, y: 0, width: width, height: height)
    #if os(iOS) || os(tvOS)
        let view = AppView(frame: frame)
    #elseif os(macOS)
        let view = FlippedView(frame: frame)
    #endif
    view.addSublayer(layer)
    return view
}

public enum IndexOrderRepresentation : Int {
    case none
    case indexLabel
    case gradient
}

public struct DebugOptions: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let flipped    = DebugOptions(rawValue: 1 << 0)
    public static let big        = DebugOptions(rawValue: 1 << 1)
    public static let gradient   = DebugOptions(rawValue: 1 << 2)
    public static let showLabels = DebugOptions(rawValue: 1 << 3)
    public static let showOrigin = DebugOptions(rawValue: 1 << 4)
}

public struct DebugConfig {
    
    public var coordinate: CoordinateSystemType = .yDown
    public var scale: CGFloat = 1.5
    public var numDivisions: Int = 5
    public var showOrigin: Bool = false
    public var indexOrderRepresentation: IndexOrderRepresentation
    
    public init(coordinate: CoordinateSystemType = .yDown,
                scale: CGFloat = 1.5,
                numDivisions: Int = 5,
                showOrigin: Bool = false,
                indexOrderRepresentation: IndexOrderRepresentation = .none) {
        
        self.coordinate               = coordinate
        self.scale                    = scale
        self.numDivisions             = numDivisions
        self.showOrigin               = showOrigin
        self.indexOrderRepresentation = indexOrderRepresentation
    }
    
    public init(options: DebugOptions) {
        self.coordinate = options.contains(.flipped) ? .yUp : .yDown
        self.scale = options.contains(.big) ? 3 : 1.5
        self.numDivisions = 5
        self.showOrigin = options.contains(.showOrigin)
        self.indexOrderRepresentation = .none
        if options.contains(.showLabels) { self.indexOrderRepresentation = .indexLabel }
        if options.contains(.gradient) { self.indexOrderRepresentation = .gradient }
    }
}

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
        let bounds = visibleRect ?? self.bounds
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
        guard let area = bounds, !area.isEmpty else { return AppView(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        let layer = CoordinateSystem(type: coordinate, area: area, scale: scale, numSegments: numDivisions, showOrigin: showOrigin)
        
        for object in debugArray {
            layer.render(object: object)
        }
        return debugLayer(layer, withMargin: layer.segmentLength)
    }
}

extension CGAffineTransform {
    
    public func debugView(of options: DebugOptions = [], use rect: AffineRect = .unit, image: CGImage? = nil) -> AppView {
        let config = DebugConfig(options: options)
        return getDebugView(in:               config.coordinate,
                            visibleRect:      nil,
                            affineRect:       rect,
                            image:            image,
                            scale:            config.scale,
                            numDivisions:     config.numDivisions,
                            showOrigin:       config.showOrigin)
    }
    
    public func getDebugView(in coordinate:CoordinateSystemType, visibleRect:CGRect? = nil, affineRect:AffineRect = .unit, image: CGImage? = nil, scale:CGFloat = 1.5, numDivisions:Int = 5, showOrigin:Bool = true) -> AppView {
        let t = AffineTransform(rect: affineRect, image: image ?? getTransformImage(), transform: self)
        return t.getDebugView(in: coordinate, visibleRect: visibleRect, scale: scale, numDivisions: numDivisions, showOrigin: showOrigin)
    }
}

// MARK: - Utilities

public func getDivision(_ value:Double, segments:Int = 5) -> Float {
    
    let logValue = log10(value)
    let exp =  logValue < 0 ? -floor(abs(logValue)) : floor(logValue)
    var bigger = pow(10, exp)
    bigger = bigger < value ? pow(10, exp+1) : bigger
    
    let step = 0.25
    for presision in [1, 2] {
        for i in stride(from: step, to: 0.05, by: -0.05) {
            for j in stride(from: i, through: 1.0, by: i) {
                let length = bigger * j
                if value == length {
                    return Float(length) / Float(segments)
                } else if value < length {
                    let division = length / Double(segments)
                    if division * Double(segments - presision) < value {
                        return Float(division)
                    }
                }
            }
        }
    }
    return Float(bigger) / Float(segments)
}

func calculatePrecision(_ value: Double) -> Int {
    let exp = log10(value)
    if exp < 0 {
        return Int(ceil(abs(exp))) + 1
    }
    return 1
}

// MARK: - NumberFormatter

extension NumberFormatter {
    
    convenience init(precision:Int) {
        self.init()
        self.numberStyle = .decimal
        self.maximumFractionDigits = precision
        self.roundingMode = .halfUp
    }
    
    func formatNumber(_ number:CGFloat) -> String {
        let number = NSNumber(value: Double(number))
        return self.string(from: number) ?? "\(number)"
    }
}

// MARK: - AppView

extension AppView {
    
    func addSublayer(_ layer:CALayer) {
        #if os(iOS)
            self.layer.addSublayer(layer)
        #elseif os(macOS)
            if self.layer == nil {
                self.layer = CALayer()
            }
            self.layer?.addSublayer(layer)
        #endif
    }
}

// MARK: - CALayer

extension CALayer {
    
    func setCenter(_ center:CGPoint) {
        let bounds = self.bounds
        let labelCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let offset = CGPoint(x: center.x - labelCenter.x, y: center.y - labelCenter.y)
        self.frame.origin = offset
    }
    
    func applyDefaultContentScale() {
        #if os(iOS)
            self.contentsScale = UIScreen.main.scale
        #elseif os(macOS)
            self.contentsScale = NSScreen.main()?.backingScaleFactor ?? 1
        #endif
    }
}

// MARK: - CATextLayer

extension CATextLayer {
    
    convenience init(text:String, attributes:[NSAttributedStringKey: Any] = [:]) {
        self.init()
        
        let string = NSAttributedString(string: text, attributes: attributes)
        let size = CGSize(width: 1000, height: 1000)
        self.frame = string.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        self.string = string
        self.applyDefaultContentScale()
    }
    
    convenience init(axisLabel:String, color:AppColor = .gray, font:AppFont? = nil) {
        self.init()
        
        let font = font ?? AppFont.default
        var attrs:[NSAttributedStringKey: Any] = [:]
        attrs[.foregroundColor] = color
        attrs[.font]            = font
        let string = NSAttributedString(string:axisLabel, attributes: attrs)
        
        let size = CGSize(width: 1000, height: 1000)
        self.frame = string.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        self.string = string
        self.applyDefaultContentScale()
    }
    
    convenience init(indexLabel:String, color:AppColor = .gray, font:AppFont? = nil) {
        self.init()
        
        let font = font ?? AppFont.default
        var attrs:[NSAttributedStringKey: Any] = [:]
        attrs[.foregroundColor] = color
        attrs[.font]            = font
        let string = NSAttributedString(string:indexLabel, attributes: attrs)
        
        let size = CGSize(width: 1000, height: 1000)
        let bounds = string.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        var width = bounds.width + bounds.height/2
        width = width < bounds.height ? bounds.height : width
        self.frame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
        
        self.string = string
        self.borderColor = color.cgColor
        self.borderWidth = 0.5
        self.cornerRadius = bounds.height/2
        self.alignmentMode = kCAAlignmentCenter
        self.applyDefaultContentScale()
    }
}

// MARK: - AppFont

extension AppFont {
    
    internal static var `default`:AppFont {
        return AppFont(name: ".HelveticaNeueInterface-Thin", size: 10) ?? AppFont.systemFont(ofSize: 10)
    }
}

// MARK: - AppColor

let colors:[Int] = [
    0x50aada, 0x8de050, 0xffdc58, 0xffb768, 0xff4d54, 0x9635af,
    0x3591c2, 0x5dbb33, 0xf2cb2e, 0xff9e35, 0xff1220, 0x63177a,
    0x267298, 0x6ba737, 0xe2af0f, 0xef932b, 0xce0e27, 0x4c0c60,
    0x074d6d, 0x4a7d23, 0xc3880a, 0xd07218, 0xaa0517, 0x360540,
]

extension AppColor {
    
    convenience init(hex:Int, alpha:CGFloat) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let b = CGFloat((hex & 0xFF)) / 255.0
        self.init(red: r, green:g, blue:b, alpha:alpha)
    }
    
    static func get(_ index:Int) -> AppColor {
        return AppColor(hex: colors[index], alpha: 1)
    }
}

func interpolate(from color0: AppColor, to color1: AppColor, ratio: CGFloat) -> AppColor {
    let comp0 = color0.cgColor.components!
    let comp1 = color1.cgColor.components!
    let r = (1 - ratio) * comp0[0] + ratio * comp1[0]
    let g = (1 - ratio) * comp0[1] + ratio * comp1[1]
    let b = (1 - ratio) * comp0[2] + ratio * comp1[2]
    let a = (1 - ratio) * comp0[3] + ratio * comp1[3]
    return AppColor(red: r, green: g, blue: b, alpha: a)
}


// MARK: - Collection

extension Collection where Iterator.Element == CGPoint {
    
    var bounds:CGRect {
        guard let pnt = self.first else { return CGRect.zero }
        var (minX, maxX, minY, maxY) = (pnt.x, pnt.x, pnt.y, pnt.y)
        
        for point in self {
            minX = point.x < minX ? point.x : minX
            minY = point.y < minY ? point.y : minY
            maxX = point.x > maxX ? point.x : maxX
            maxY = point.y > maxY ? point.y : maxY
        }
        return CGRect(x: minX, y: minY, width: (maxX-minX), height: (maxY-minY))
    }
}

// MARK: - CGPoint

extension CGPoint {
    
    func getBezierPath(radius: CGFloat) -> AppBezierPath {
        let x = (self.x - radius/2.0)
        let y = (self.y - radius/2.0)
        let rect = CGRect(x: x, y: y, width: radius, height: radius)
        return AppBezierPath(ovalIn: rect)
    }
    
    var length:CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }
    
    func normalized(to length:CGFloat = 1) -> CGPoint {
        let len = length/self.length
        return CGPoint(x: self.x * len, y: self.y * len)
    }
}

func +(p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPoint(x: p1.x + p2.x, y: p1.y + p2.y)
}

func -(p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
}

func calculateAngle(_ point1:CGPoint, _ point2:CGPoint) -> CGFloat {
    return atan2(point2.y - point1.y, point2.x - point1.x)
}

func calculateDistance(_ point1:CGPoint, _ point2:CGPoint) -> CGFloat {
    let x = point2.x - point1.x
    let y = point2.y - point1.y
    return sqrt(x*x + y*y)
}

func calculateCenter(_ point1:CGPoint, _ point2:CGPoint) -> CGPoint {
    return CGPoint(x: point1.x+(point2.x-point1.x)/2.0, y: point1.y+(point2.y-point1.y)/2.0)
}

// MARK: - CGRect

extension CGRect {
    
    public static let unit: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    
    public var affineRect: AffineRect {
        return AffineRect(x: origin.x, y: origin.y, width: width, height: height)
    }
}

// MARK: - CGAffineTransform

extension CGAffineTransform {
    
    func rotated(by angle: CGFloat) -> CGAffineTransform {
        return self * CGAffineTransform(rotationAngle: angle)
    }
    
    func scaledBy(x sx: CGFloat, y sy: CGFloat) -> CGAffineTransform {
        return self * CGAffineTransform(scaleX: sx, y: sy)
    }
    
    func translatedBy(x tx: CGFloat, y ty: CGFloat) -> CGAffineTransform {
        return self * CGAffineTransform(translationX: tx, y: ty)
    }
    
    // mutating
    mutating func rotate(by angle:CGFloat) {
        self = self.rotated(by: angle)
    }
    
    mutating func scaleBy(x:CGFloat, y:CGFloat)  {
        self = self.scaledBy(x: x, y: y)
    }
    
    mutating func translateBy(x:CGFloat, y:CGFloat) {
        self = self.translatedBy(x: x, y: y)
    }
    
    mutating func invert() {
        self = self.inverted()
    }
}

func * (m1: CGAffineTransform, m2: CGAffineTransform) -> CGAffineTransform {
    return m1.concatenating(m2)
}

func * (p:CGPoint, m: CGAffineTransform) -> CGPoint {
    return p.applying(m)
}

func *(lhs: [CGPoint], rhs: CGAffineTransform) -> [CGPoint] {
    return lhs.map{ $0 * rhs }
}

#if os(macOS)
    
    import AppKit
    
    public extension NSImage {
        
        public var cgImage: CGImage? {
            return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
        }
    }
    
    public extension NSBezierPath {
        
        public var cgPath: CGPath {
            let path = CGMutablePath()
            guard self.elementCount > 0 else { return path }
            var points = [NSPoint](repeating: NSPoint.zero, count: 3)
            
            for index in 0..<elementCount {
                let pathType = self.element(at: index, associatedPoints: &points)
                switch pathType {
                case .moveToBezierPathElement:    path.move(to: points[0])
                case .lineToBezierPathElement:    path.addLine(to: points[0])
                case .curveToBezierPathElement:   path.addCurve(to: points[2], control1: points[0], control2: points[1])
                case .closePathBezierPathElement: path.closeSubpath()
                }
            }
            return path
        }
        
        public func apply(_ t:CGAffineTransform) {
            let transform = AppKit.AffineTransform(m11: t.a, m12: t.b, m21: t.c, m22: t.d, tX: t.tx, tY: t.ty)
            self.transform(using: transform)
        }
        
        public func addLine(to point:CGPoint) {
            self.line(to: point)
        }
        
        public func addCurve(to point:CGPoint, controlPoint1 point1:CGPoint, controlPoint2 point2:CGPoint) {
            self.curve(to: point, controlPoint1: point1, controlPoint2: point2)
        }
        
        private func interpolate(_ p1:CGPoint, _ p2:CGPoint, _ ratio:CGFloat) -> CGPoint {
            return CGPoint(x: p1.x + (p2.x-p1.x) * ratio, y: p1.y + (p2.y-p1.y) * ratio)
        }
        
        public func addQuadCurve(to end:CGPoint, controlPoint:CGPoint) {
            let start = self.currentPoint
            let control1 = interpolate(start, controlPoint, 0.666666)
            let control2 = interpolate(end,   controlPoint, 0.666666)
            self.curve(to: end, controlPoint1: control1, controlPoint2: control2)
        }
        
        public func addArc(withCenter center:CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
            self.appendArc(withCenter: center, radius : radius, startAngle : startAngle, endAngle : endAngle, clockwise : clockwise)
        }
    }
    
#endif


// AffineRect for rendering image

public struct AffineRect {
    
    public var v0: CGPoint // top left
    public var v1: CGPoint // top right
    public var v2: CGPoint // bottom right
    public var v3: CGPoint // bottom left
    
    public init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.v0 = CGPoint(x: x,       y: y)
        self.v1 = CGPoint(x: x+width, y: y)
        self.v2 = CGPoint(x: x+width, y: y+height)
        self.v3 = CGPoint(x: x,       y: y+height)
    }
    
    public init(v0: CGPoint, v1: CGPoint, v2: CGPoint, v3: CGPoint) {
        self.v0 = v0
        self.v1 = v1
        self.v2 = v2
        self.v3 = v3
    }
}

extension AffineRect {
    public static let unit: AffineRect = AffineRect(x: 0, y: 0, width: 1, height: 1)
    public var bounds: CGRect { return [v0, v1, v2, v3].bounds }
    public var center: CGPoint { return calculateCenter(v0, v2) }
    public var angle: CGFloat { return calculateAngle(v0, v1) }
    public var width: CGFloat { return calculateDistance(v0, v1) }
    public var height: CGFloat { return calculateDistance(v0, v3) }
}

public func * (rect: AffineRect, t: CGAffineTransform) -> AffineRect {
    let v0 = rect.v0.applying(t)
    let v1 = rect.v1.applying(t)
    let v2 = rect.v2.applying(t)
    let v3 = rect.v3.applying(t)
    return AffineRect(v0: v0, v1: v1, v2: v2, v3: v3)
}


/// axis label alway hold the correct value, no matter current position
struct AxisLabel {
    var label: CATextLayer
    var position: CGPoint
    
    func applying(_ transform: CGAffineTransform) -> AxisLabel {
        let position = self.position.applying(transform)
        return AxisLabel(label: self.label, position: position)
    }
}

func *(labels: [AxisLabel], transform: CGAffineTransform) -> [AxisLabel] {
    return labels.map{ $0.applying(transform) }
}

struct AxisSegment {
    var start: CGPoint
    var end: CGPoint
    
    func getLabels(axis: AxisType, segmentValue: CGFloat, numSegments: Int, numFormater: NumberFormatter) -> [AxisLabel] {
        switch axis {
        case .x:
            return (0 ... numSegments).map {
                let value = start.x + CGFloat($0) * segmentValue
                let string = numFormater.formatNumber(value)
                let label = CATextLayer(axisLabel: string)
                let position = CGPoint(x: value, y: start.y)
                return AxisLabel(label: label, position: position)
            }
        case .y:
            return (0 ... numSegments).map {
                let value = start.y + CGFloat($0) * segmentValue
                let string = numFormater.formatNumber(value)
                let label = CATextLayer(axisLabel: string)
                let position = CGPoint(x: start.x, y: value)
                return AxisLabel(label: label, position: position)
            }
        }
    }
}

struct AxisArrow {
    
    let w1: CGFloat = 0
    let w2: CGFloat = 5
    let h: CGFloat = 3
    
    var path: AppBezierPath {
        let path = AppBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: -w1, y:  h))
        path.addLine(to: CGPoint(x:  w2, y:  0))
        path.addLine(to: CGPoint(x: -w1, y: -h))
        path.addLine(to: .zero)
        path.close()
        return path
    }
    
    func pathAtEndOfSegment(segStart p0: CGPoint, segEnd p1: CGPoint) -> AppBezierPath {
        let angle = atan2(p1.y-p0.y, p1.x-p0.x)
        var t = CGAffineTransform(rotationAngle: angle)
        t = t.concatenating(CGAffineTransform(translationX: p1.x, y: p1.y))
        let p = self.path
        p.apply(t)
        return p
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

public protocol Debuggable {
    var bounds: CGRect { get }
    func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor)
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

// MARK: - AffineTransform

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

// MARK: - AffineImage

public struct AffineImage {
    
    public var image: CGImage
    public var rect: AffineRect
    public var opacity: CGFloat
}

func clockwiseInYDown(v0: CGPoint, v1: CGPoint, v2: CGPoint) -> Bool {
    return (v2.x - v0.x) * (v1.y - v2.y) < (v2.y - v0.y) * (v1.x - v2.x)
}

extension AffineImage : Debuggable {
    
    public var bounds: CGRect {
        return rect.bounds
    }
    
    public func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor) {
        let target = self.rect * transform
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
        
        layer.addSublayer(imageLayer)
    }
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


// TODO: - Axis implements Debuggable also
