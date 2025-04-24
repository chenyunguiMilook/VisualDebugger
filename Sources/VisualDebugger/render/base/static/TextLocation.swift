//
//  TextPoint.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import VisualUtils

public enum TextLocation: String, Sendable {
    case center
    case left, right, top, bottom
    case topLeft, topRight, bottomLeft, bottomRight
}

extension TextLocation {
    var anchor: Anchor {
        switch self {
        case .center:
            return .midCenter
        case .left:
            return .midRight
        case .right:
            return .midLeft
        case .top:
            return .btmCenter
        case .bottom:
            return .topCenter
        case .topLeft:
            return .btmRight
        case .topRight:
            return .btmLeft
        case .bottomLeft:
            return .topRight
        case .bottomRight:
            return .topLeft
        }
    }
}
