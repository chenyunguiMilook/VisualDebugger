//
//  AppBezierPath+.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/7/28.
//

import CoreGraphics
import VisualUtils
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension AppBezierPath {
    
    public func getPath(
        name: String? = nil,
        color: AppColor = .yellow,
        style: Path.PathStyle = .stroke()
    ) -> Path {
        Path(
            path: self,
            name: name,
            transform: .identity,
            color: color,
            style: style
        )
    }
}
