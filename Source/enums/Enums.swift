//
//  Enums.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics
#if os(iOS) || os(tvOS)
import UIKit
#else
import Cocoa
#endif

public enum CoordinateSystemType {
    case yDown, yUp
}

public enum AxisType {
    case x, y
}

public enum IndexOrderRepresentation : Int {
    case none
    case indexLabel
    case gradient
}

public protocol Debuggable {
    var bounds: CGRect { get }
    func debug(in layer: CALayer, with transform: CGAffineTransform, color: AppColor)
}








