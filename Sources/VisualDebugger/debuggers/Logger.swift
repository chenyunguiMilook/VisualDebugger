//
//  Logs.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/22.
//

import Foundation
import CoreGraphics
import VisualUtils

public typealias VLogger = Logger

public final class Logger: @unchecked Sendable {
    // 单例模式
    public static let `default`: Logger = .init()
    
    // 日志结构体
    public struct Log {
        public enum Level {
            case debug
            case info
            case warning
            case error
            case critical
            
            // 返回对应颜色
            var color: AppColor {
                switch self {
                case .debug:
                    return .gray
                case .info:
                    return .green
                case .warning:
                    return .yellow
                case .error:
                    return .red
                case .critical:
                    return .purple
                }
            }
            
            // 返回显示名称
            var displayName: String {
                switch self {
                case .debug: return "DEBUG"
                case .info: return "INFO"
                case .warning: return "WARNING"
                case .error: return "ERROR"
                case .critical: return "CRITICAL"
                }
            }
        }
        
        public var message: String
        public var level: Level
    }
    
    // 线程安全队列
    private let queue = DispatchQueue(label: "logger.queue")
    private var logs: [Log] = []
    public var maxLogs: Int = 500
    
    // 私有初始化，确保单例
    private init() {}
    
    // 核心日志记录方法
    func logging(_ messages: [Any], level: Logger.Log.Level = .info, separator: String = ", ") {
        let stringMessage = messages.map { String(reflecting: $0) }.joined(separator: separator)
        let log = Logger.Log(message: stringMessage, level: level)
        queue.sync {
            logs.append(log)
            if logs.count > maxLogs {
                logs.removeFirst(logs.count - maxLogs)
            }
            // 打印到控制台，包含时间戳和级别
            //let timestamp = ISO8601DateFormatter().string(from: Date())
            //print("[\(timestamp)] [\(level.displayName)] \(message)")
        }
    }
    
    // 便利方法，按经典命名标准实现
    public func debug(_ message: Any...) {
        logging(message, level: .debug)
    }
    
    public func info(_ message: Any...) {
        logging(message, level: .info)
    }
    
    public func warning(_ message: Any...) {
        logging(message, level: .warning)
    }
    
    public func error(_ message: Any...) {
        logging(message, level: .error)
    }
    
    public func critical(_ message: Any...) {
        logging(message, level: .critical)
    }
    
    // 可选：获取所有日志的方法
    public func getLogs() -> [Log] {
        queue.sync {
            return logs
        }
    }

    public func clear() {
        queue.sync {
            logs.removeAll()
        }
    }
}

extension TextRenderStyle {
    public static func log(color: AppColor) -> TextRenderStyle {
        TextRenderStyle(
            font: AppFont.italicSystemFont(ofSize: 10),
            insets: .zero,
            margin: AppEdgeInsets(top: 2, left: 10, bottom: 2, right: 2),
            anchor: .topLeft,
            textStroke: .init(color: .black, width: -30),
            textColor: color
        )
    }
}

extension Logger.Log {
    func textElement(at position: CGPoint) -> StaticTextElement? {
        guard !message.isEmpty else { return nil }
        return StaticTextElement(source: .string(message), style: .log(color: self.level.color), position: position)
    }
}

extension Array where Element == Logger.Log {
    public func render(
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int?
    ) {
        var y: CGFloat = 25
        let lineHeight: CGFloat = 12
        for log in self {
            let element = log.textElement(at: CGPoint(x: 0, y: y))
            element?.render(with: .identity, in: context, scale: scale, contextHeight: contextHeight)
            y += lineHeight
        }
    }
}
