//
//  DebugCapture.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/6.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class DebugCapture: @unchecked Sendable {
    
    public let context: DebugContext
    public let scale: Double
    public let folder: URL
    
    private var imageCaches: [AppImage] = []
    
    public init(context: DebugContext, folder: URL, scale: Double = 2) {
        self.context = context
        self.scale = scale
        self.folder = folder
    }
    
    public func captureObjects(
        _ action: String? = nil,
        @DebugBuilder builder: () -> [any Debuggable]
    ) {
        var elements = builder().map{ $0.debugElements }.flatMap{ $0 }
        if let action {
            let textElement = TextElement(source: .string(action), style: .nameLabel)
            let text = StaticTextElement(content: textElement, position: context.coordinate.valueRect.bottomCenter)
            elements.append(text)
        }
        
        if let image = context.getImage(scale: scale, elements: elements) {
            imageCaches.append(image)
        }
    }
    
    public func captureElements(
        _ action: String? = nil,
        @RenderBuilder builder: () -> [any ContextRenderable]
    ) {
        var elements = builder()
        if let action {
            let textElement = TextElement(source: .string(action), style: .nameLabel)
            let text = StaticTextElement(content: textElement, position: context.coordinate.valueRect.bottomCenter)
            elements.append(text)
        }
        
        if let image = context.getImage(scale: scale, elements: elements) {
            imageCaches.append(image)
        }
    }
    
    public func output() {
        do {
            try FileManager.default.createDirectory(
                at: folder,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            print("Failed to create directory: \(error)")
            return
        }
        for (i, image) in imageCaches.enumerated() {
            let fileName = String(format: "%05d.png", i + 1)
            let fileURL = folder.appendingPathComponent(fileName)
            do {
                #if os(iOS)
                var imageData = image.pngData()
                #elseif os(macOS)
                var imageData: Data?
                if let tiffData = image.tiffRepresentation,
                   let bitmapRep = NSBitmapImageRep(data: tiffData),
                   let data = bitmapRep.representation(using: .png, properties: [:]) {
                    imageData = data
                }
                #endif
                if let imageData {
                    try imageData.write(to: fileURL)
                } else {
                    print("Failed to convert image at index \(i) to PNG data")
                }
            } catch {
                print("Failed to save image \(fileName): \(error)")
            }
        }
        imageCaches.removeAll()
    }
}

extension DebugCapture {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var _shared: DebugCapture?
    public static var shared: DebugCapture? {
        get {
            lock.lock()
            let value = _shared
            lock.unlock()
            return value
        }
        set {
            lock.lock()
            _shared = newValue
            lock.unlock()
        }
    }
}
