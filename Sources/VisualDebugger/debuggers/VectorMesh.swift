//
//  VectorMesh.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/11.
//

import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class VectorMesh: GeometryDebugger {
    
    public let faces: [VectorTriangle]
    
    public lazy var faceElements: [VectorTriangleRenderElement] = getMeshFaces()

    public init(
        faces: [VectorTriangle],
        name: String? = nil,
        transform: Matrix2D = .identity,
        color: AppColor = .yellow,
        faceStyleDict: [Int: FaceStyle] = [:],
        displayOptions: DisplayOptions = .face,
        labelStyle: TextRenderStyle = .nameLabel,
        useColorfulLabel: Bool = false
    ) {
        self.faces = faces
        
        super.init(
            name: name, 
            transform: transform,
            color: color,
            faceStyleDict: faceStyleDict,
            displayOptions: displayOptions,
            labelStyle: labelStyle,
            useColorfulLable: useColorfulLabel
        )
    }
    
    // 设置面样式
    public func setFaceStyle(
        at index: Int,
        style: PathStyle? = nil,
        label: LabelStyle? = nil
    ) -> VectorMesh {
        guard index < faces.count else { return self }
        let style = FaceStyle(
            style: style,
            label: label
        )
        self.faceStyleDict[index] = style
        return self
    }
    
    public func setFaceStyle(
        _ style: FaceStyle,
        for indices: Range<Int>?
    ) -> VectorMesh {
        let idxs = indices ?? 0 ..< faces.count
        for i in idxs {
            self.faceStyleDict[i] = style
        }
        return self
    }
    
    public func useColorfulLabel(_ value: Bool) -> Self {
        self.useColorfulLabel = value
        return self
    }
    
    // MARK: - modifier
    public func show(_ option: DisplayOptions) -> Self {
        self.displayOptions = option
        return self
    }
    
    public func log(_ message: String, _ level: Logger.Log.Level = .info) -> Self {
        self.logging(message, level)
        return self
    }

    func getMeshFaces() -> [VectorTriangleRenderElement] {
        faces.enumerated().map { (i, triangle) in
            createFace(
                triangle: triangle,
                faceIndex: i
            )
        }
    }
    
    func createFace(
        triangle: VectorTriangle,
        faceIndex: Int
    ) -> VectorTriangleRenderElement {
        let customStyle = faceStyleDict[faceIndex]
        
        var labelString: String?
        if let faceLabel = customStyle?.label?.text {
            switch faceLabel {
            case .string(let string):
                labelString = string
            case .coordinate:
                // 计算三角形的中心点
                let center = (triangle.segment.start + triangle.segment.end + triangle.vertex) / 3.0
                labelString = "\(center)"
            case .index:
                labelString = "\(faceIndex)"
            case .orientation:
                // 使用 VectorTriangle 的 orientationSymbol 属性
                labelString = triangle.orientationSymbol
            }
        }
        
        let textColor: AppColor? = if useColorfulLabel { customStyle?.style?.color ?? self.color } else { nil }
        var label: TextElement?
        if let labelString {
            if let labelStyle = customStyle?.label?.style {
                label = TextElement(text: labelString, style: labelStyle)
            } else {
                label = TextElement(
                    text: labelString,
                    defaultStyle: labelStyle,
                    location: customStyle?.label?.location ?? .center,
                    textColor: textColor
                )
            }
        }
        
        return VectorTriangleRenderElement(
            triangle: triangle,
            transform: transform,
            style: getFaceRenderStyle(style: customStyle?.style),
            label: label
        )
    }
}

// MARK: - Transformable, DebugRenderable
extension VectorMesh: Transformable, DebugRenderable {
    public var debugBounds: CGRect? {
        // 计算所有三角形的边界框
        var bounds: CGRect?
        
        for face in faces {
            // 使用 VectorTriangle 的 bounds 属性
            let faceBounds = face.bounds
            if !faceBounds.isEmpty {
                if let currentBounds = bounds {
                    bounds = currentBounds.union(faceBounds)
                } else {
                    bounds = faceBounds
                }
            }
        }
        
        if let bounds = bounds {
            return bounds * transform
        }
        
        return nil
    }
    
    public func applying(transform: Matrix2D) -> VectorMesh {
        VectorMesh(
            faces: faces,
            name: name,
            transform: self.transform * transform,
            color: color,
            faceStyleDict: faceStyleDict,
            displayOptions: displayOptions,
            labelStyle: labelStyle,
            useColorfulLabel: useColorfulLabel
        )
    }
    
    public func render(with transform: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        // 只渲染面
        if displayOptions.contains(.face) {
            for face in faceElements {
                face.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
            }
        }
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    // 创建一些示例三角形
    let triangle1 = VectorTriangle(
        segment: .init(
            start: CGPoint(x: 50, y: 50),
            control1: CGPoint(x: 70, y: 30),
            control2: CGPoint(x: 90, y: 30),
            end: CGPoint(x: 110, y: 50)
        ),
        vertex: CGPoint(x: 80, y: 100)
    )
    
    let triangle2 = VectorTriangle(
        segment: .init(
            start: CGPoint(x: 110, y: 50),
            control1: CGPoint(x: 130, y: 70),
            control2: CGPoint(x: 150, y: 70),
            end: CGPoint(x: 170, y: 50)
        ),
        vertex: CGPoint(x: 140, y: 100)
    )
    
    DebugView(showOrigin: true) {
        VectorMesh(faces: [triangle1, triangle2])
            .setFaceStyle(at: 0, style: .init(color: .blue.withAlphaComponent(0.2)), label: .index())
            .setFaceStyle(at: 1, style: .init(color: .red.withAlphaComponent(0.2)), label: .coordinate())
    }
}
