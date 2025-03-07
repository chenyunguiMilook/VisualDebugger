//
//  AppColor+Behavior.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/7.
//

import CoreGraphics

extension AppColor {
    private static let colors: [UInt32] = [
        0x50AADA, 0x8DE050, 0xFFDC58, 0xFFB768, 0xFF4D54, 0x9635AF,
        0x3591C2, 0x5DBB33, 0xF2CB2E, 0xFF9E35, 0xFF1220, 0x63177A,
        0x267298, 0x6BA737, 0xE2AF0F, 0xEF932B, 0xCE0E27, 0x4C0C60,
        0x074D6D, 0x4A7D23, 0xC3880A, 0xD07218, 0xAA0517, 0x360540,
    ]
}

extension AppColor {
    public convenience init(rgb: UInt32, alpha: CGFloat = 1) {
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0xFF00) >> 8) / 255.0
        let b = CGFloat((rgb & 0xFF) >> 0) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    public static var randomColor: AppColor {
        let value: UInt32 = colors.randomElement()!
        return AppColor(rgb: value, alpha: 1)
    }

    public static subscript(_ index: Int) -> AppColor {
        let index = index % colors.count
        let value = colors[index]
        return AppColor(rgb: value, alpha: 1)
    }
}
