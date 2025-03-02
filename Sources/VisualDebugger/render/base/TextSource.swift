//
//  TextSource.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import Foundation

public enum TextSource {
    
    case string(String)
    case number(Double, formatter: NumberFormatter)
    
}
