//
//  TextRenderStyle.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension TextRenderStyle {
    
    public static let `default` = TextRenderStyle(
        font: AppFont.systemFont(ofSize: 10),
        insets: .zero,
        margin: .zero,
        cornerRadius: 0,
        anchor: .topLeft,
        textColor: AppColor.white
    )
    
    public static let xAxisLabel = TextRenderStyle(
        font: AppFont(name: "HelveticaNeueInterface-Thin", size: 10) ?? AppFont.systemFont(ofSize: 10),
        insets: .zero,
        margin: AppEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
        cornerRadius: 0,
        anchor: .topCenter,
        textColor: AppColor.lightGray
    )
    
    public static let yAxisLabel = TextRenderStyle(
        font: AppFont(name: "HelveticaNeueInterface-Thin", size: 10) ?? AppFont.systemFont(ofSize: 10),
        insets: .zero,
        margin: AppEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
        cornerRadius: 0,
        anchor: .midRight,
        textColor: AppColor.lightGray
    )
    
    public static let originLabel = TextRenderStyle(
        font: AppFont.italicSystemFont(ofSize: 10),
        insets: .zero,
        margin: AppEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
        cornerRadius: 0,
        anchor: .topRight,
        textColor: AppColor.lightGray
    )
    
    public static let indexLabel = TextRenderStyle(
        font: AppFont.italicSystemFont(ofSize: 10),
        insets: .zero,
        margin: AppEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
        cornerRadius: 4,
        anchor: .midCenter,
        textColor: AppColor.white,
        bgColor: .blue
    )
}

extension ShapeRenderStyle {
    
    public static let axis = ShapeRenderStyle(
        stroke: Stroke(color: AppColor.lightGray.withAlphaComponent(0.5), style: .init(lineWidth: 1))
    )
    public static let arrow = ShapeRenderStyle(
        fill: Fill(color: AppColor.lightGray.withAlphaComponent(0.5), style: .init())
    )
}
