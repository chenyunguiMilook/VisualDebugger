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

extension TextLocation {
    @usableFromInline
    static let `default` = TextLocation.right
}

public class BaseDebugger {
    public typealias Vertex = PointRenderElement
    public typealias Edge = SegmentRenderElement

    public enum VertexShape {
        case shape(ShapeRenderer)
        case index
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
    public enum EdgeShape {
        case line
        case arrow(Arrow)
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
    public struct VertexStyle {
        let shape: VertexShape?
        let style: Style?
        let label: Description?
    }
    public struct EdgeStyle {
        let shape: EdgeShape?
        let style: Style?
        let label: Description?
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
    
    public let transform: Matrix2D
    public let vertexShape: VertexShape
    public let edgeShape: EdgeShape
    public let color: AppColor
    public var vertexStyleDict: [Int: VertexStyle]
    public var edgeStyleDict: [Int: EdgeStyle] = [:]
    public var displayOptions: DisplayOptions

    public init(
        transform: Matrix2D = .identity,
        vertexShape: VertexShape = .shape(Circle(radius: 2)),
        edgeShape: EdgeShape = .arrow(Arrow()),
        color: AppColor = .yellow,
        vertexStyleDict: [Int: VertexStyle] = [:],
        edgeStyleDict: [Int: EdgeStyle] = [:],
        displayOptions: DisplayOptions = .all
    ) {
        self.transform = transform
        self.vertexShape = vertexShape
        self.edgeShape = edgeShape
        self.color = color
        self.vertexStyleDict = vertexStyleDict
        self.edgeStyleDict = edgeStyleDict
        self.displayOptions = displayOptions
    }
    
    func getRadius(index: Int) -> Double {
        let shape = self.vertexStyleDict[index]?.shape ?? vertexShape
        switch shape {
        case .shape(let shape): return shape.radius
        case .index: return 6
        }
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

    func edgeStyle(style: Style?) -> ShapeRenderStyle {
        let color = style?.color ?? color
        guard let mode = style?.mode else {
            return ShapeRenderStyle(
                stroke: .init(color: color, style: .init(lineWidth: 1)),
                fill: nil
            )
        }
        switch mode {
        case .stroke(dashed: let dashed):
            let dash: [CGFloat] = dashed ? [5, 5] : []
            return ShapeRenderStyle(
                stroke: .init(color: color, style: .init(lineWidth: 1, dash: dash)),
                fill: .init(color: color, style: .init())
            )
        case .fill:
            return ShapeRenderStyle(
                stroke: .init(color: color, style: .init(lineWidth: 1)),
                fill: .init(color: color, style: .init())
            )
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

