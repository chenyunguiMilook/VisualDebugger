//
//  EdgeStyle.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/28.
//


public enum EdgeStyle { // for each pair of vertics
    public struct ArrowOptions: OptionSet, Sendable {
        public var rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        public static let start = Self(rawValue: 1 << 0)
        public static let end = Self(rawValue: 1 << 1)
        public static let all: Self = [.start, .end]
    }
    case arrow(name: NameStyle? = nil, color: AppColor? = nil, options: ArrowOptions = .end, dashed: Bool = false)
}
