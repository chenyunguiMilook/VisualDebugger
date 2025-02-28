//
//  VertexStyle.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/28.
//


public enum VertexStyle {
    case shape(PointStyle.Shape, name: String? = nil)
    case label(String, name: String? = nil)
    case index(name: String? = nil)
}
