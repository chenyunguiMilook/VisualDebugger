# VisualDebugger

[中文文档](./readme-cn.md)

The most elegant and easiest way to visualize your data in source files

## Features

- [x] Support for multiple coordinate systems (yUp, yDown)
- [x] Visual debugging of Mesh structures
- [x] Visual debugging of Points collections with customizable styles
- [x] Visual debugging of Bezier paths
- [x] Support for iOS and macOS platforms
- [x] Flexible style customization system
- [x] Detailed coordinate axis display and labeling

## Requirements

- iOS 17.0+ | macOS 15+
- Swift 6.0+
- Xcode 16+

## Installation

#### Swift Package Manager

You can use [Swift Package Manager](https://swift.org/package-manager) to install `VisualDebugger` by adding it to your `Package.swift` file:

```swift
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/chenyunguiMilook/VisualDebugger.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "YOUR_TARGET_NAME",
            dependencies: ["VisualDebugger"]),
    ]
)
```

## Usage Examples

### Debugging Points

```swift
#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    DebugView {
        Points([
            .init(x: 40, y: 10),
            .init(x: 10, y: 23),
            .init(x: 23, y: 67)
        ], vertexShape: .index)
        .setVertexStyle(at: 0, shape: .shape(Circle(radius: 2)), label: "Corner")
        .setVertexStyle(at: 1, style: .init(color: .red), label: .coordinate())
        .setEdgeStyle(at: 2, shape: .arrow(.doubleArrow), style: .init(color: .red, mode: .fill))
        .show([.vertex, .edge])
    }
    .coordinateVisible(true)
    .coordinateStyle(.default)
    .coordinateSystem(.yDown)
    //.zoom(1.5, aroundCenter: .init(x: 10, y: 23))
}
```

<img src="./Images/debug_points.png" title="Debug Points" />

### Debugging Mesh Structures

```swift
#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    let vertices = [
        CGPoint(x: 50, y: 50),
        CGPoint(x: 150, y: 50),
        CGPoint(x: 100, y: 150),
        CGPoint(x: 200, y: 150)
    ]
    
    let faces = [
        Mesh.Face(0, 1, 2),
        Mesh.Face(1, 3, 2)
    ]
    
    DebugView(showOrigin: true) {
        Mesh(vertices, faces: faces)
            .setVertexStyle(at: 0, shape: .index, label: .coordinate(at: .top))
            .setVertexStyle(at: 1, style: .init(color: .red), label: "顶点1")
            .setEdgeStyle(for: .init(org: 2, dst: 1), style: .init(color: .green))
            .setFaceStyle(at: 0, color: .blue, alpha: 0.2)
    }
}
```

<img src="./Images/debug_mesh.png" title="Debug Mesh" />

## License

VisualDebugger is available under the MIT license. See the LICENSE file for more info.
