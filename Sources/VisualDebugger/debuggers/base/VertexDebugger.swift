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
    public var name: String?
    public let transform: Matrix2D
    public let color: AppColor
    public let vertexShape: VertexShape
    public var displayOptions: DisplayOptions

    public init(
        name: String? = nil,
        transform: Matrix2D,
        color: AppColor,
        vertexShape: VertexShape = .shape(Circle(radius: 2)),
        displayOptions: DisplayOptions = .all
    ) {
        self.name = name
        self.transform = transform
        self.color = color
        self.vertexShape = vertexShape
        self.displayOptions = displayOptions
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
        vertexStyle: VertexStyle?
    ) -> Vertex {
        
        if let style = vertexStyle {
            var nameString: String?
            if let name = style.label {
                switch name {
                case .string(let string, _):
                    nameString = string
                case .coordinate:
                    nameString = "(\(position.x), \(position.y))"
                case .index:
                    nameString = "\(index)"
                }
            }
            return createVertex(
                index: index,
                position: position,
                shape: style.shape,
                style: style.style,
                name: nameString,
                nameLocation: style.label?.location,
                transform: transform
            )
        } else {
            return createVertex(
                index: index,
                position: position,
                shape: nil,
                style: nil,
                name: nil,
                nameLocation: nil,
                transform: transform
            )
        }
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

    public enum VertexShape: Sendable {
        case shape(ShapeRenderer)
        case index
    }
    
    public struct VertexStyle: Sendable {
        let shape: VertexShape?
        let style: Style?
        let label: Description?
        public init(shape: VertexShape?, style: Style?, label: Description?) {
            self.shape = shape
            self.style = style
            self.label = label
        }
    }
    
    public struct Style: Sendable {
        public enum Mode: Sendable {
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

    public enum Description: Sendable {
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
    
    public struct DisplayOptions: OptionSet, Sendable {
        public var rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        public static let vertex = Self.init(rawValue: 1 << 0)
        public static let edge = Self.init(rawValue: 1 << 1)
        public static let face = Self.init(rawValue: 1 << 2)
        public static let all: Self = [.vertex, .edge, .face]
    }
}

extension VertexDebugger.Description: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self = .string(value, at: .right)
    }
}
