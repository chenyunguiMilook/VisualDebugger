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
    
    func getVertexRenderStyle(style: PathStyle?) -> ShapeRenderStyle {
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
        if let vertexLabel = customStyle?.label?.text {
            switch vertexLabel {
            case .string(let string):
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
        let textColor = useColorfulLabel ? color : nil
        let label = TextElement(text: labelString, location: customStyle?.label?.location ?? .right, textColor: textColor)
        let element = PointElement(shape: centerShape, label: label)
        return PointRenderElement(content: element, position: position, transform: transform)
    }
}

extension TextElement {
    public convenience init?(text: String?, location: TextLocation, textColor: AppColor?, rotatable: Bool = false) {
        guard let text else { return nil }
        var style: TextRenderStyle = .nameLabel
        style.setTextLocation(location)
        if let textColor { style.textColor = textColor }
        self.init(source: .string(text), style: style, rotatable: rotatable)
    }
}

extension VertexDebugger {
    
    public typealias Vertex = PointRenderElement

    public struct VertexStyle: Sendable {
        let shape: VertexShape?
        let style: PathStyle?
        let label: LabelStyle?
        public init(shape: VertexShape?, style: PathStyle?, label: LabelStyle?) {
            self.shape = shape
            self.style = style
            self.label = label
        }
    }

    public enum VertexShape: Sendable {
        case shape(ShapeRenderer)
        case index
    }
    
    public struct PathStyle: Sendable {
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
    
    public struct LabelStyle: Sendable {
        public enum Text: Sendable {
            case string(String)
            case coordinate
            case index
        }
        public var text: Text?
        public var location: TextLocation?
        public var style: TextRenderStyle?
        public var rotatable: Bool?
        
        public init(text: Text? = nil, location: TextLocation? = nil, style: TextRenderStyle? = nil, rotatable: Bool? = nil) {
            self.text = text
            self.location = location
            self.style = style
            self.rotatable = rotatable
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

extension VertexDebugger.LabelStyle.Text: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension VertexDebugger.LabelStyle: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self = .init(text: .string(value))
    }
}

extension VertexDebugger.LabelStyle {
    public static func string(_ string: String, at location: TextLocation? = nil, style: TextRenderStyle? = nil, rotatable: Bool? = nil) -> Self {
        Self.init(text: .string(string), location: location, style: style, rotatable: rotatable)
    }
    public static func coordinate(at location: TextLocation? = nil, style: TextRenderStyle? = nil, rotatable: Bool? = nil) -> Self {
        Self.init(text: .coordinate, location: location, style: style, rotatable: rotatable)
    }
    public static func index(at location: TextLocation? = nil, style: TextRenderStyle? = nil, rotatable: Bool? = nil) -> Self {
        Self.init(text: .index, location: location, style: style, rotatable: rotatable)
    }
}

