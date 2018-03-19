//
//  AxisSegment.swift
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

struct AxisSegment {
    var start: CGPoint
    var end: CGPoint
    
    func getLabels(axis: AxisType, segmentValue: CGFloat, numSegments: Int, numFormater: NumberFormatter) -> [AxisLabel] {
        switch axis {
        case .x:
            return (0 ... numSegments).map {
                let value = start.x + CGFloat($0) * segmentValue
                let string = numFormater.formatNumber(value)
                let label = CATextLayer(axisLabel: string)
                let position = CGPoint(x: value, y: start.y)
                return AxisLabel(label: label, position: position)
            }
        case .y:
            return (0 ... numSegments).map {
                let value = start.y + CGFloat($0) * segmentValue
                let string = numFormater.formatNumber(value)
                let label = CATextLayer(axisLabel: string)
                let position = CGPoint(x: start.x, y: value)
                return AxisLabel(label: label, position: position)
            }
        }
    }
}
