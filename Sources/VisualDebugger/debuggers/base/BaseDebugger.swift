//
//  BaseDebugger.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/22.
//

import CoreGraphics

public class BaseDebugger {
    
    public var name: String?
    public let transform: Matrix2D
    public let color: AppColor
    public var logs: [Logger.Log] = []
    
    public init(
        name: String? = nil,
        transform: Matrix2D,
        color: AppColor
    ) {
        self.name = name
        self.transform = transform
        self.color = color
    }
    
    func logging(_ messages: [Any], level: Logger.Log.Level = .info, separator: String = ", ") {
        let stringMessage = messages.map { String(reflecting: $0) }.joined(separator: separator)
        let log = Logger.Log(message: stringMessage, level: level)
        self.logs.append(log)
    }
}
