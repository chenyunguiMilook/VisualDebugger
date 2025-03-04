//
//  AxisData.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import CoreGraphics
import Foundation

package struct AxisData {
    public static let sideRatio = 0.6
    public static let maxSideLength: Double = 20

    // start value of the axis
    package var startValue: CGFloat
    // length value of the axis
    package var lengthValue: CGFloat
    // the value of each segment
    package var segmentValue: CGFloat
    // number segments of starting (reach to 0)
    package var startSegments: Int
    // total segments
    package var numSegments: Int

    /// the origin value in the coordinate system
    package var originValue: CGFloat {
        return self.startValue + self.segmentValue * CGFloat(self.startSegments)
    }

    /// end value of the axis
    package var endValue: CGFloat {
        return self.startValue + self.lengthValue
    }

    package var marks: [Double] {
        (0...numSegments).map{
            startValue + Double($0) * segmentValue
        }
    }
    
    package init(min minValue: CGFloat, max maxValue: CGFloat, segmentValue: CGFloat) {
        self.startValue = floor(minValue / segmentValue) * segmentValue
        self.segmentValue = segmentValue
        self.startSegments = Int(ceil(abs(self.startValue) / segmentValue))
        self.numSegments = Int(ceil((maxValue - self.startValue) / segmentValue))
        self.lengthValue = segmentValue * CGFloat(self.numSegments)
    }

    package func getAxis(type: Axis.Kind) -> Axis {
        Axis(
            type: type,
            start: startValue,
            end: endValue,
            marks: marks,
            side: min(segmentValue * Self.sideRatio, Self.maxSideLength)
        )
    }
}
