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

public enum IndexOrderRepresentation : Int {
    case none
    case indexLabel
    case gradient
}

public protocol Debuggable {
    var bounds: CGRect { get }
    func debug(in coordinate: CoordinateSystem)
}








