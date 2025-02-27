//
//  TextRenderStyle+Bg.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/27.
//

extension TextRenderStyle {
        
    public enum BgStyle {
        case rect(color: AppColor, filled: Bool)
        case roundRect(radius: Double, color: AppColor, filled: Bool)
        case capsule(color: AppColor, filled: Bool)
    }
}


extension TextRenderStyle.BgStyle {
    
    public var color: AppColor {
        switch self {
        case .rect(let color, _):
            return color
        case .roundRect(_, let color, _):
            return color
        case .capsule(let color, _):
            return color
        }
    }
    
    public var filled: Bool {
        switch self {
        case .rect(_, let filled):
            filled
        case .roundRect(_, _, let filled):
            filled
        case .capsule(_, let filled):
            filled
        }
    }
}
