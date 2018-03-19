//
//  NumberFormater+Behavior.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics

extension NumberFormatter {
    
    convenience init(precision:Int) {
        self.init()
        self.numberStyle = .decimal
        self.maximumFractionDigits = precision
        self.roundingMode = .halfUp
    }
    
    func formatNumber(_ number:CGFloat) -> String {
        let number = NSNumber(value: Double(number))
        return self.string(from: number) ?? "\(number)"
    }
}
