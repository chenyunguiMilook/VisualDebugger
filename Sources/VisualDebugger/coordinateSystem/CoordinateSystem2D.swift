//
//  CoordinateSystem2D.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


import Foundation

public enum CoordinateSystem2D: Int, Sendable {
    public static let UIKit: CoordinateSystem2D = .yDown
    public static let UV: CoordinateSystem2D = .yUp
    public static let OpenGL: CoordinateSystem2D = .yUp

    case yDown, yUp
}

extension CoordinateSystem2D {
    public var flipped: Self {
        switch self {
        case .yDown: return .yUp
        case .yUp: return .yDown
        }
    }
}
