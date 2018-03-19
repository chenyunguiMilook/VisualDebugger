//
//  AxisLabel.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#else
import Cocoa
#endif

/// axis label alway hold the correct value, no matter current position
struct AxisLabel {
    var label: CATextLayer
    var position: CGPoint
    
    func applying(_ transform: CGAffineTransform) -> AxisLabel {
        let position = self.position.applying(transform)
        return AxisLabel(label: self.label, position: position)
    }
}

func *(labels: [AxisLabel], transform: CGAffineTransform) -> [AxisLabel] {
    return labels.map{ $0.applying(transform) }
}

