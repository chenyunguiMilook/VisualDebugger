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
        if let faceLabel = customStyle?.label {
            switch faceLabel {
            case .string(let string, _):
                labelString = string
            case .coordinate:
                labelString = "\(vertices.gravityCenter)"
            case .index:
                labelString = "\(faceIndex)"
            }
        }
        let label = TextElement(text: labelString, location: customStyle?.label?.location ?? .center, textColor: textColor)
        return FaceRenderElement(
            points: vertices,
            transform: transform,
            style: getFaceRenderStyle(style: customStyle?.style),
            label: label
        )
    }
}


extension GeometryDebugger {
    public typealias MeshEdge = SegmentRenderElement
    public typealias MeshFace = FaceRenderElement
    
    public struct FaceStyle {
        let style: PathStyle?
        let label: Description?
        
        public init(style: PathStyle?, label: Description?) {
            self.style = style
            self.label = label
        }
    }
}
