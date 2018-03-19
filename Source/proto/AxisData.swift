//
//  File.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics

public struct AxisData {
    
    // start value of the axis
    public var startValue:CGFloat
    // length value of the axis
    public var lengthValue: CGFloat
    // the value of each segment
    public var segmentValue:CGFloat
    // number segments of starting (reach to 0)
    public var startSegments:Int
    // total segments
    public var numSegments:Int
    
    /// the origin value in the coordinate system
    public var originValue: CGFloat {
        return self.startValue + self.segmentValue * CGFloat(self.startSegments)
    }
    
    /// end value of the axis
    public var endValue: CGFloat {
        return self.startValue + self.lengthValue
    }
    
    public init(min minValue:CGFloat, max maxValue:CGFloat, segmentValue:CGFloat) {
        self.startValue = floor(minValue / segmentValue) * segmentValue
        self.segmentValue = segmentValue
        self.startSegments = Int(ceil(abs(startValue) / segmentValue))
        self.numSegments = Int(ceil((maxValue-startValue) / segmentValue))
        self.lengthValue = segmentValue * CGFloat(numSegments)
    }
}
