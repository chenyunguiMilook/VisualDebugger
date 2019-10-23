//
//  AppView.swift
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

#if os(macOS)
internal class FlippedView: AppView {
    override var isFlipped: Bool { return true }
}
#endif

extension AppView {
    
    func addSublayer(_ layer:CALayer) {
        #if os(iOS)
        self.layer.addSublayer(layer)
        #elseif os(macOS)
        if self.layer == nil {
            self.layer = CALayer()
        }
        self.layer?.addSublayer(layer)
        #endif
    }
}

// MARK: - CALayer

extension CALayer {
    
    func setCenter(_ center:CGPoint) {
        let bounds = self.bounds
        let labelCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let offset = CGPoint(x: center.x - labelCenter.x, y: center.y - labelCenter.y)
        self.frame.origin = offset
    }
    
    func applyDefaultContentScale() {
        #if os(iOS)
        self.contentsScale = UIScreen.main.scale
        #elseif os(macOS)
        self.contentsScale = NSScreen.main?.backingScaleFactor ?? 1
        #endif
    }
}
