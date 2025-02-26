//
//  Anchor.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import CoreGraphics
import Foundation

public enum Anchor: String, Codable, CaseIterable, Sendable {
    case topLeft, topCenter, topRight
    case midLeft, midCenter, midRight
    case btmLeft, btmCenter, btmRight
}

extension Anchor {

    public var anchor: CGPoint {
        switch self {
        case .topLeft:
            CGPoint(x: 0.0, y: 0.0)
        case .topCenter:
            CGPoint(x: 0.5, y: 0.0)
        case .topRight:
            CGPoint(x: 1.0, y: 0.0)
        case .midLeft:
            CGPoint(x: 0.0, y: 0.5)
        case .midCenter:
            CGPoint(x: 0.5, y: 0.5)
        case .midRight:
            CGPoint(x: 1.0, y: 0.5)
        case .btmLeft:
            CGPoint(x: 0.0, y: 1.0)
        case .btmCenter:
            CGPoint(x: 0.5, y: 1.0)
        case .btmRight:
            CGPoint(x: 1.0, y: 1.0)
        }
    }
}
