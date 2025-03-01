//
//  VertexStyle.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/28.
//


public enum VertexStyle {
    case shape(PointStyle.Shape, name: NameStyle? = nil)
    case label(LabelStyle, name: NameStyle? = nil)
    case index(name: NameStyle? = nil)
}
