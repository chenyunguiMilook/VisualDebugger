//
//  CATextLayer+Behavior.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#else
import Cocoa
#endif

extension CATextLayer {
    
    convenience init(text:String, attributes:[NSAttributedStringKey: Any] = [:]) {
        self.init()
        
        let string = NSAttributedString(string: text, attributes: attributes)
        let size = CGSize(width: 1000, height: 1000)
        self.frame = string.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        self.string = string
        self.applyDefaultContentScale()
    }
    
    convenience init(axisLabel:String, color:AppColor = .gray, font:AppFont? = nil) {
        self.init()
        
        let font = font ?? AppFont.default
        var attrs:[NSAttributedStringKey: Any] = [:]
        attrs[.foregroundColor] = color
        attrs[.font]            = font
        let string = NSAttributedString(string:axisLabel, attributes: attrs)
        
        let size = CGSize(width: 1000, height: 1000)
        self.frame = string.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        self.string = string
        self.applyDefaultContentScale()
    }
    
    convenience init(indexLabel:String, color:AppColor = .gray, font:AppFont? = nil) {
        self.init()
        
        let font = font ?? AppFont.default
        var attrs:[NSAttributedStringKey: Any] = [:]
        attrs[.foregroundColor] = color
        attrs[.font]            = font
        let string = NSAttributedString(string:indexLabel, attributes: attrs)
        
        let size = CGSize(width: 1000, height: 1000)
        let bounds = string.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        var width = bounds.width + bounds.height/2
        width = width < bounds.height ? bounds.height : width
        self.frame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
        
        self.string = string
        self.borderColor = color.cgColor
        self.borderWidth = 0.5
        self.cornerRadius = bounds.height/2
        self.alignmentMode = kCAAlignmentCenter
        self.applyDefaultContentScale()
    }
}
