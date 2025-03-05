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
        self.vertexStyleDict = vertexStyleDict
        self.edgeStyleDict = edgeStyleDict
        self.displayOptions = displayOptions
        super.init(
            transform: transform,
            color: color,
            vertexShape: vertexShape,
            edgeShape: edgeShape
        )
    }
    
    func getRadius(index: Int) -> Double {
        let shape = self.vertexStyleDict[index]?.shape ?? vertexShape
        switch shape {
        case .shape(let shape): return shape.radius
        case .index: return 6
        }
    }
}

