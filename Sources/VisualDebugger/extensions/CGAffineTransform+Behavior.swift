//
//  CGAffineTransform.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


import Accelerate
import CoreGraphics
import Foundation
import simd

extension CGAffineTransform {

    public static let identity = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)

    public var isIdentity: Bool {
        return self.a == 1 && self.b == 0 && self.c == 0 && self.d == 1 && self.tx == 0
            && self.ty == 0
    }

    public var determinant: CGFloat {
        return a * d - b * c
    }

    public var isInvertible: Bool {
        return determinant != 0
    }

    // MARK: Initialize

    public init(rotate radian: CGFloat, aroundCenter center: CGPoint) {
        let cosa = cos(radian)
        let sina = sin(radian)
        let a = cosa
        let b = sina
        let c = -sina
        let d = cosa
        let tx = center.y * sina - center.x * cosa + center.x
        let ty = -center.y * cosa - center.x * sina + center.y
        self.init(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }

    public init(scale: CGFloat, aroundCenter center: CGPoint) {
        let a = scale
        let b: CGFloat = 0
        let c: CGFloat = 0
        let d = scale
        let tx = center.x - center.x * scale
        let ty = center.y - center.y * scale
        self.init(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }
    
    public init(scaleX: CGFloat, scaleY: CGFloat, aroundCenter center: CGPoint) {
        let a = scaleX
        let b: CGFloat = 0
        let c: CGFloat = 0
        let d = scaleY
        let tx = center.x - center.x * scaleX
        let ty = center.y - center.y * scaleY
        self.init(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }

    public init(skew: Double, aroundCenter center: CGPoint, alongAngle angle: Double) {
        let moveBackM = CGAffineTransform(translation: CGPoint(x: -center.x, y: -center.y))
        let rotateBackM = CGAffineTransform(rotationAngle: -angle)
        let skewM = CGAffineTransform(skewX: skew, y: 0)
        let rotateM = CGAffineTransform(rotationAngle: angle)
        let moveM = CGAffineTransform(translation: center)
        self = moveBackM * rotateBackM * skewM * rotateM * moveM
    }
    
    public init(translate: CGFloat, alongAngle radian: CGFloat) {
        let cosa = cos(radian)
        let sina = sin(radian)
        let cc = cosa * cosa
        let ss = sina * sina
        let a = cc + ss
        let b: CGFloat = 0
        let c: CGFloat = 0
        let d = ss + cc
        let tx = translate * cosa
        let ty = translate * sina
        self.init(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }

    public init(scale: CGFloat, alongAngle angle: CGFloat) {
        let ax = cos(angle)
        let ay = sin(angle)
        let a = 1 + (scale - 1) * ax * ax
        let b = (scale - 1) * ax * ay
        let c = b
        let d = 1 + (scale - 1) * ay * ay
        let tx: CGFloat = 0
        let ty: CGFloat = 0
        self.init(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }

    public init(scale: CGFloat, aroundCenter center: CGPoint, alongAngle angle: CGFloat) {
        let ax = cos(angle)
        let ay = sin(angle)
        let a = 1 + (scale - 1) * ax * ax
        let b = (scale - 1) * ax * ay
        let c = b
        let d = 1 + (scale - 1) * ay * ay
        let tx = -center.x * a - center.y * c + center.x
        let ty = -center.x * b - center.y * d + center.y
        self.init(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }
    
    public init(flipVertically height: CGFloat, scaleFactor: CGFloat = 1) {
        let a = scaleFactor
        let b: CGFloat = 0
        let c: CGFloat = 0
        let d = -scaleFactor
        let tx: CGFloat = 0
        let ty = height
        self.init(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }

    public init(transform m: CGAffineTransform, aroundCenter center: CGPoint) {
        let x = center.x - center.x * m.a - center.y * m.c + m.tx
        let y = center.y - center.x * m.b - center.y * m.d + m.ty
        self.init(a: m.a, b: m.b, c: m.c, d: m.d, tx: x, ty: y)
    }

    public init(translationX tx: CGFloat, y ty: CGFloat) {
        self.init(a: 1, b: 0, c: 0, d: 1, tx: tx, ty: ty)
    }
    
    public init(translation: CGPoint) {
        let tx = translation.x
        let ty = translation.y
        self.init(a: 1, b: 0, c: 0, d: 1, tx: tx, ty: ty)
    }
    
    public init(scale: CGFloat) {
        let a = scale
        let d = scale
        self.init(a: a, b: 0, c: 0, d: d, tx: 0, ty: 0)
    }
    
    /// skew and does not affect scale
    /// - Parameters:
    ///   - sx: skew x in radian
    ///   - sy: skew y in radian
    public init(skewX sx: Double, y sy: Double) {
        let a: CGFloat = 1
        let b = tan(sy)
        let c = tan(sx)
        let d: CGFloat = 1
        self.init(a: a, b: b, c: c, d: d, tx: 0, ty: 0)
    }
    
    public init(shearingX sx: Double, y sy: Double) {
        let a: CGFloat = 1
        let b: CGFloat = sy
        let c: CGFloat = sx
        let d: CGFloat = 1
        self.init(a: a, b: b, c: c, d: d, tx: 0, ty: 0)
    }

    // MARK: Transforms
    public func inverted() -> CGAffineTransform {
        CGAffineTransformInvert(self)
    }

    public mutating func invert() {
        self = self.inverted()
    }

    // MARK: decompose and transforms

    public func getScale() -> (scaleX: CGFloat, scaleY: CGFloat) {
        let scaleX = sqrt(self.a * self.a + self.b * self.b)
        let scaleY = sqrt(self.c * self.c + self.d * self.d)
        return (scaleX, scaleY)
    }

    public func getRotation() -> CGFloat {
        let skewX = atan2(-self.c, self.d)
        let skewY = atan2(self.b, self.a)
        return abs(skewX - skewY) < 0.000001 ? skewX : 0
    }
    
    public func decompose() -> (
        tx: CGFloat, ty: CGFloat, scaleX: CGFloat, scaleY: CGFloat, rotation: CGFloat,
        skewX: CGFloat,
        skewY: CGFloat
    ) {
        let scaleX = sqrt(self.a * self.a + self.b * self.b)
        let scaleY = sqrt(self.c * self.c + self.d * self.d)
        var skewX = atan2(-self.c, self.d)
        var skewY = atan2(self.b, self.a)
        var rotation: CGFloat = 0
        if skewX == skewY {
            rotation = skewY
            skewX = 0
            skewY = 0
        }
        return (
            tx: self.tx, ty: self.ty, scaleX: scaleX, scaleY: scaleY, rotation: rotation,
            skewX: skewX,
            skewY: skewY
        )
    }
    
    public func transform(point: CGPoint) -> CGPoint {
        return point.applying(self)
    }

    public func transform(rect: CGRect) -> CGRect {
        return rect.applying(self)
    }
}

extension CGAffineTransform {

    public var float3x3: simd_float3x3 {
        return simd_float3x3([
            SIMD3<Float>([Float(a), Float(c), Float(tx)]),
            SIMD3<Float>([Float(b), Float(d), Float(ty)]),
            SIMD3<Float>([0, 0, 1]),
        ])
    }
    
    public var float3x3_transposed: simd_float3x3 {
        return simd_float3x3([
            SIMD3<Float>([Float(a), Float(b), 0]),
            SIMD3<Float>([Float(c), Float(d), 0]),
            SIMD3<Float>([Float(tx), Float(ty), 1]),
        ])
    }
}

public func * (m1: CGAffineTransform, m2: CGAffineTransform) -> CGAffineTransform {
    m1.concatenating(m2)
}

public func * (p: CGPoint, m: CGAffineTransform) -> CGPoint {
    p.applying(m)
}

public func *(p: [CGPoint], m: CGAffineTransform) -> [CGPoint] {
    p.map{ $0 * m }
}

public func * (r: CGRect, m: CGAffineTransform) -> CGRect {
    return r.applying(m)
}

public func stretchFit(rect: CGRect, into target: CGRect) -> CGAffineTransform {
    // 1. move to origin
    let tx = -rect.origin.x
    let ty = -rect.origin.y
    // 2. scale match size
    let sx = target.width / rect.width
    let sy = target.height / rect.height
    // 3. move to target origin
    let mx = target.origin.x
    let my = target.origin.y
    // 4. compsoe matrix multiply result
    return CGAffineTransform(a: sx, b: 0, c: 0, d: sy, tx: tx * sx + mx, ty: ty * sy + my)
}
