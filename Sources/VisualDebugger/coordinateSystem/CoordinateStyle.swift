//
//  CoordinateStyle.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/4.
//

import VisualUtils

public struct CoordinateStyle: @unchecked Sendable {
    
    public let xAxisColor: AppColor
    public let yAxisColor: AppColor
    public let originColor: AppColor
    
    public init(xAxisColor: AppColor, yAxisColor: AppColor, originColor: AppColor) {
        self.xAxisColor = xAxisColor
        self.yAxisColor = yAxisColor
        self.originColor = originColor
    }
}

extension CoordinateStyle {
    public static let `default`: Self = .init(
        xAxisColor: .lightGray.withAlphaComponent(0.5),
        yAxisColor: .lightGray.withAlphaComponent(0.5),
        originColor: .lightGray
    )
    
    public static let color: Self = .init(
        xAxisColor: .red.withAlphaComponent(0.5),
        yAxisColor: .green.withAlphaComponent(0.5),
        originColor: .lightGray
    )
}
