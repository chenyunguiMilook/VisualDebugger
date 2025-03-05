//
//  VertexDebugger.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/5.
//

import CoreGraphics

extension TextLocation {
    @usableFromInline
    static let `default` = TextLocation.right
}

public class VertexDebugger {
    
    public let transform: Matrix2D
    public let color: AppColor
    public let vertexShape: VertexShape

    public init(
        transform: Matrix2D,
        color: AppColor,
        vertexShape: VertexShape = .shape(Circle(radius: 2))
    ) {
        self.transform = transform
        self.color = color
        self.vertexShape = vertexShape
    }
    
    func vertexStyle(style: Style?) -> ShapeRenderStyle {
        let color = style?.color ?? color
        guard let mode = style?.mode else {
            return ShapeRenderStyle(fill: .init(color: color, style: .init()))
        }
        switch mode {
        case .stroke(dashed: let dashed):
            let dash: [CGFloat] = dashed ? [5, 5] : []
            return ShapeRenderStyle(stroke: .init(color: color, style: .init(lineWidth: 1, dash: dash)))
        case .fill:
            return ShapeRenderStyle(fill: .init(color: color, style: .init()))
        }
    }
    
    func labelStyle(color: AppColor) -> TextRenderStyle {
        TextRenderStyle(
            font: AppFont.italicSystemFont(ofSize: 10),
            insets: .zero,
            margin: AppEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
            anchor: .midCenter,
            textColor: color,
            bgStyle: .capsule(color: color, filled: false)
        )
    }

    func createVertex(
        index: Int,
        position: CGPoint,
        shape: VertexShape?,
        style: Style?,
        name: String?,
        nameLocation: TextLocation?,
        transform: Matrix2D
    ) -> Vertex {
        let shape = shape ?? self.vertexShape
        let color = style?.color ??  self.color
        let centerShape: StaticRendable = switch shape {
        case .shape(let shape):
            ShapeElement(renderer: shape, style: vertexStyle(style: style))
        case .index:
            TextElement(source: .index(index), style: labelStyle(color: color))
        }
        var label: TextElement?
        if let name {
            var nameStyle: TextRenderStyle = .nameLabel
            nameStyle.setTextLocation(nameLocation ?? .right)
            label = TextElement(source: .string(name), style: nameStyle)
        }
        let element = PointElement(shape: centerShape, label: label)
        return PointRenderElement(content: element, position: position, transform: transform)
    }

}

extension VertexDebugger {
    
    public typealias Vertex = PointRenderElement

    public enum VertexShape {
        case shape(ShapeRenderer)
        case index
    }
    
    public struct VertexStyle {
        let shape: VertexShape?
        let style: Style?
        let label: Description?
    }
    
    public struct Style {
        public enum Mode {
            case stroke(dashed: Bool)
            case fill
        }
        let color: AppColor?
        let mode: Mode?
        public init(color: AppColor?, mode: Mode? = nil) {
            self.color = color
            self.mode = mode
        }
    }

    public enum Description {
        case string(String, at: TextLocation = .default)
        case coordinate(at: TextLocation = .default)
        case index(at: TextLocation = .default)
        
        public var location: TextLocation {
            switch self {
            case .string(_, let location): location
            case .coordinate(let location): location
            case .index(let location): location
            }
        }
    }
}

extension VertexDebugger.Description: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self = .string(value, at: .right)
    }
}
