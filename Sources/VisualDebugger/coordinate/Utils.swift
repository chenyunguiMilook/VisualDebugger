//
//  Utils.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import CoreGraphics

func getDivision(_ value: Double, segments: Int = 5) -> Double {
    // 处理输入值为 0 的情况
    guard value != 0 else { return 0 }
    
    // 计算近似步长
    let test = abs(value) / Double(segments)
    
    // 计算数量级的指数
    let exp = floor(log10(test))
    
    // 计算基数 p = 10^exp
    let p = pow(10, exp)
    
    // 定义“漂亮”数字的倍数
    let multipliers = [1.0, 2.0, 2.5, 5.0, 10.0]
    
    // 生成候选步长
    let candidates = multipliers.map { $0 * p }
    
    // 找到最小的候选步长 >= test
    for c in candidates {
        if c >= test {
            return c
        }
    }
    
    // 理论上不会到达这里，但为安全起见返回最后一个候选值
    return candidates.last ?? 0
}

func calculatePrecision(_ value: Double) -> Int {
    let exp = log10(value)
    if exp < 0 {
        return Int(ceil(abs(exp))) + 1
    }
    return 1
}

func clockwiseInYDown(v0: CGPoint, v1: CGPoint, v2: CGPoint) -> Bool {
    return (v2.x - v0.x) * (v1.y - v2.y) < (v2.y - v0.y) * (v1.x - v2.x)
}
