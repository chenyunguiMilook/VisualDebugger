//
//  AppBezierPath.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


import Foundation
import CoreGraphics

extension AppBezierPath {
    
    public static func xArrow(size: Double) -> AppBezierPath {
        let half = size / 2
        let path = AppBezierPath()
        path.move(to: .zero)
        path.addLine(to: .init(x: 0, y: -half))
        path.addLine(to: .init(x: size, y: 0))
        path.addLine(to: .init(x: 0, y: half))
        path.addLine(to: .zero)
        path.close()
        return path
    }
    
    public static func yUpArrow(size: Double) -> AppBezierPath {
        let p = xArrow(size: size)
        return (p * Matrix2D(rotationAngle: -.pi/2))!
    }
    
    public static func yDownArrow(size: Double) -> AppBezierPath {
        let p = xArrow(size: size)
        return (p * Matrix2D(rotationAngle: .pi/2))!
    }
    
    public static func xMark(size: Double) -> AppBezierPath {
        let path = AppBezierPath()
        path.move(to: .zero)
        path.addLine(to: .init(x: 0, y: -size))
        return path
    }
    
    public static func yMark(size: Double) -> AppBezierPath {
        let path = AppBezierPath()
        path.move(to: .zero)
        path.addLine(to: .init(x: size, y: 0))
        return path
    }
}

func *(lhs: AppBezierPath, rhs: Matrix2D) -> AppBezierPath? {
    guard let cgPath = lhs.cgPath * rhs else { return nil }
    return AppBezierPath(cgPath: cgPath)
}
func *(lhs: CGPath, rhs: Matrix2D) -> CGPath? {
    var t = rhs
    return lhs.copy(using: &t)
}
