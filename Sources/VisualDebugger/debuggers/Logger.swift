//
//  Logs.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/22.
//

import Foundation

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
    
    // 私有初始化，确保单例
    private init() {}
    
    // 核心日志记录方法
    public func log(_ level: Log.Level, message: String) {
        let log = Log(message: message, level: level)
        queue.sync {
            logs.append(log)
            // 打印到控制台，包含时间戳和级别
            //let timestamp = ISO8601DateFormatter().string(from: Date())
            //print("[\(timestamp)] [\(level.displayName)] \(message)")
        }
    }
    
    // 便利方法，按经典命名标准实现
    public func debug(_ message: String) {
        log(.debug, message: message)
    }
    
    public func info(_ message: String) {
        log(.info, message: message)
    }
    
    public func warning(_ message: String) {
        log(.warning, message: message)
    }
    
    public func error(_ message: String) {
        log(.error, message: message)
    }
    
    public func critical(_ message: String) {
        log(.critical, message: message)
    }
    
    // 可选：获取所有日志的方法
    public func getLogs() -> [Log] {
        queue.sync {
            return logs
        }
    }
}
