//
//  Customizable.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//


//public protocol PointShapeCustomizable {
//    func setPointShape(_ shape: VertexShape) -> Self
//}

public protocol EndpointShapeCustomizable {
    //func setEndpointShape(_ shape: )
}

public protocol ColorCustomizable {
    func setColor(_ color: AppColor) -> Self
}

public protocol LineWidthCustomizable {
    func setLineWidth(_ width: Double) -> Self
}

public protocol AnchorCustomizable {
    func setAnchor(_ anchor: Anchor) -> Self
}

public protocol FillCustomizable {
    func setFill(_ fill: Bool) -> Self
}

//public protocol LocationCustomizable {
//    func setLocation(_ location: NameStyle.Location) -> Self
//}
