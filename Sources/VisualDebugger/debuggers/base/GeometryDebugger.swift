//
//  BaseDebugger.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/5.
//
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import VisualUtils

public class GeometryDebugger: SegmentDebugger {

    public let faceStyle: FaceStyle
    public var faceStyleDict: [Int: FaceStyle] = [:]

    public init(
        name: String? = nil,
        transform: Matrix2D = .identity,
        vertexShape: VertexShape = .shape(Circle(radius: 2)),
        edgeShape: EdgeShape = .arrow(Arrow()),
        color: AppColor = .yellow,
        vertexStyleDict: [Int: VertexStyle] = [:],
        edgeStyleDict: [Int: EdgeStyle] = [:],
        faceStyleDict: [Int: FaceStyle] = [:],
        displayOptions: DisplayOptions = .all,
        labelStyle: TextRenderStyle = .nameLabel,
        useColorfulLable: Bool = false
    ) {
        self.faceStyle = FaceStyle(style: .init(color: color.withAlphaComponent(0.2)), label: nil)
        self.faceStyleDict = faceStyleDict
        super.init(
            name: name, 
            transform: transform,
            color: color,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            displayOptions: displayOptions,
            labelStyle: labelStyle,
            useColorfulLable: useColorfulLable,
            vertexStyleDict: vertexStyleDict,
            edgeStyleDict: edgeStyleDict
        )
    }
    
    func getFaceRenderStyle(style: PathStyle?) -> ShapeRenderStyle {
        let color = style?.color ?? color.withAlphaComponent(0.2)
        guard let mode = style?.mode else {
            return ShapeRenderStyle(
                stroke: nil,
                fill: .init(color: color)
            )
        }
        switch mode {
        case .stroke(dashed: let dashed):
            let dash: [CGFloat] = dashed ? [5, 5] : []
            return ShapeRenderStyle(
                stroke: .init(color: color, style: .init(lineWidth: 1, dash: dash)),
                fill: nil
            )
        case .fill:
            return ShapeRenderStyle(
                stroke: nil,
                fill: .init(color: color, style: .init())
            )
        }
    }
    
    func createFace(
        vertices: [CGPoint],
        faceIndex: Int
    ) -> FaceRenderElement {
        let customStyle = faceStyleDict[faceIndex]
        
        var labelString: String?
        if let faceLabel = customStyle?.label?.text {
            switch faceLabel {
            case .string(let string):
                labelString = string
            case .coordinate:
                labelString = "\(vertices.gravityCenter)"
            case .index:
                labelString = "\(faceIndex)"
            case .orientation:
                labelString = vertices.polyIsCCW ? "↺" : "↻"
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
        return FaceRenderElement(
            points: vertices,
            transform: transform,
            style: getFaceRenderStyle(style: customStyle?.style),
            label: label
        )
    }
}

extension GeometryDebugger {
    public typealias MeshFace = FaceRenderElement
    
    public struct FaceStyle {
        let style: PathStyle?
        let label: LabelStyle?
        
        public init(style: PathStyle?, label: LabelStyle?) {
            self.style = style
            self.label = label
        }
    }
}
