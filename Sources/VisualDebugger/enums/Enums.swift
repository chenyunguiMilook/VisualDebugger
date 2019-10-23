//
//  Enums.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics

public protocol Debuggable {
    var bounds: CGRect { get }
    func debug(in coordinate: CoordinateSystem, color: AppColor?)
}








