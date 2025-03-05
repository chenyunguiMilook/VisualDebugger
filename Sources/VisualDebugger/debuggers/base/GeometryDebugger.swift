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

    public var edgeStyleDict: [Int: EdgeStyle] = [:]

    public init(
        name: String? = nil,
        transform: Matrix2D = .identity,
        vertexShape: VertexShape = .shape(Circle(radius: 2)),
        edgeShape: EdgeShape = .arrow(Arrow()),
        color: AppColor = .yellow,
        vertexStyleDict: [Int: VertexStyle] = [:],
        edgeStyleDict: [Int: EdgeStyle] = [:],
        displayOptions: DisplayOptions = .all
    ) {
        self.edgeStyleDict = edgeStyleDict
        super.init(
            name: name, 
            transform: transform,
            color: color,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            displayOptions: displayOptions,
            vertexStyleDict: vertexStyleDict
        )
    }
    
}

