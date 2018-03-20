//
//  AppFont.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/20.
//

import Foundation

extension AppFont {
    
    internal static var `default`:AppFont {
        return AppFont(name: ".HelveticaNeueInterface-Thin", size: 10) ?? AppFont.systemFont(ofSize: 10)
    }
}


