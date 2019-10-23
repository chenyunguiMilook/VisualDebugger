//
//  AppColor.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics

let colors:[Int] = [
    0x50aada, 0x8de050, 0xffdc58, 0xffb768, 0xff4d54, 0x9635af,
    0x3591c2, 0x5dbb33, 0xf2cb2e, 0xff9e35, 0xff1220, 0x63177a,
    0x267298, 0x6ba737, 0xe2af0f, 0xef932b, 0xce0e27, 0x4c0c60,
    0x074d6d, 0x4a7d23, 0xc3880a, 0xd07218, 0xaa0517, 0x360540,
]

extension AppColor {
    
    convenience init(hex:Int, alpha:CGFloat) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let b = CGFloat((hex & 0xFF)) / 255.0
        self.init(red: r, green:g, blue:b, alpha:alpha)
    }
    
    static func get(_ index:Int) -> AppColor {
        return AppColor(hex: colors[index], alpha: 1)
    }
}

func interpolate(from color0: AppColor, to color1: AppColor, ratio: CGFloat) -> AppColor {
    let comp0 = color0.cgColor.components!
    let comp1 = color1.cgColor.components!
    let r = (1 - ratio) * comp0[0] + ratio * comp1[0]
    let g = (1 - ratio) * comp0[1] + ratio * comp1[1]
    let b = (1 - ratio) * comp0[2] + ratio * comp1[2]
    let a = (1 - ratio) * comp0[3] + ratio * comp1[3]
    return AppColor(red: r, green: g, blue: b, alpha: a)
}

