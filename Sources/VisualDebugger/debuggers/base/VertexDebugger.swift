//
//  VertexDebugger.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/5.
//

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
