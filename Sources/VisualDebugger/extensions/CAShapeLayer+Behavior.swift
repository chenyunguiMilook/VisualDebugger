//
//  CAShapeLayer.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/20.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#else
import Cocoa
#endif

extension CAShapeLayer {
    
    convenience init(path: CGPath, strokeColor: AppColor?, fillColor: AppColor?, lineWidth: CGFloat) {
        self.init()
        self.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        self.path = path
        self.strokeColor = strokeColor?.cgColor
        self.fillColor = fillColor?.cgColor
        self.lineWidth = lineWidth
        self.applyDefaultContentScale()
    }
}
