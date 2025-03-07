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
    public var useColorfulLabel: Bool

    var vertexStyleDict: [Int: VertexStyle]

    var textColor: AppColor? {
        useColorfulLabel ? color : nil
    }
    
    public init(
        name: String? = nil,
        transform: Matrix2D,
        color: AppColor,
        vertexShape: VertexShape = .shape(Circle(radius: 2)),
        vertexStyleDict: [Int: VertexStyle] = [:],
        displayOptions: DisplayOptions = .all,
        useColorfulLable: Bool = false
    ) {
        self.name = name
        self.transform = transform
        self.color = color
        self.vertexShape = vertexShape
        self.vertexStyleDict = vertexStyleDict
        self.displayOptions = displayOptions
        self.useColorfulLabel = useColorfulLable
    }
    
    func getVertexRenderStyle(style: Style?) -> ShapeRenderStyle {
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
    
    func getLabelRenderStyle(color: AppColor) -> TextRenderStyle {
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
        position: CGPoint
    ) -> Vertex {
        let customStyle = vertexStyleDict[index]
        var labelString: String?
        if let vertexLabel = customStyle?.label {
            switch vertexLabel {
            case .string(let string, _):
                labelString = string
            case .coordinate:
                labelString = "(\(position.x), \(position.y))"
            case .index:
                labelString = "\(index)"
            }
        }
        let shape = customStyle?.shape ?? self.vertexShape
        let color = customStyle?.style?.color ??  self.color
        let centerShape: StaticRendable = switch shape {
        case .shape(let shape):
            ShapeElement(renderer: shape, style: getVertexRenderStyle(style: customStyle?.style))
        case .index:
            TextElement(source: .index(index), style: getLabelRenderStyle(color: color))
        }
        let label = TextElement(text: labelString, location: customStyle?.label?.location ?? .right, textColor: textColor)
        let element = PointElement(shape: centerShape, label: label)
        return PointRenderElement(content: element, position: position, transform: transform)
    }
}

extension TextElement {
    public convenience init?(text: String?, location: TextLocation, textColor: AppColor?) {
        guard let text else { return nil }
        var style: TextRenderStyle = .nameLabel
        style.setTextLocation(location)
        if let textColor { style.textColor = textColor }
        self.init(source: .string(text), style: style)
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
