//
//  CGRect+.swift
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

extension CGRect {
    public func getPath(
        name: String? = nil,
        color: AppColor = .yellow,
        style: Path.PathStyle = .stroke()
    ) -> Path {
        Path(
            path: AppBezierPath(rect: self),
            name: name,
            transform: .identity,
            color: color,
            style: style
        )
    }
}
