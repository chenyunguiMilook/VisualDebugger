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
    DebugView(elements: [
        Points([
            .init(x: 40, y: 10),
            .init(x: 10, y: 23),
            .init(x: 23, y: 67)
        ], vertexShape: .index)
        .overrideVertexStyle(at: 0, shape: .shape(.rect), name: .string("Corner"))
        .overrideVertexStyle(at: 1, color: .red, name: .coordinate)
        .overrideEdgeStyle(at: 0, shape: .arrow(style: .triangle, direction: .normal), color: .red)
        
    ], coordinateSystem: .yDown)
}
```

<img src="./Images/debug_points.png" title="Debug Points" />

### Debugging Mesh Structures

```swift
#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    // Example: Create a simple triangular mesh
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
    
    return DebugView(elements: [
        Mesh(vertices, faces: faces)
            .overrideVertexStyle(at: 0, shape: .index, name: .coordinate, nameLocation: .top)
            .overrideVertexStyle(at: 1, color: .red, name: .string("Vertex 1"))
            .overrideEdgeStyle(for: .init(org: 2, dst: 1), color: .green)
            .overrideFaceStyle(at: 0, color: .blue, alpha: 0.2)
            .setDisplay(vertices: true, edges: true, faces: true)
    ], showOrigin: true, coordinateSystem: .yDown)
}
```

<img src="./Images/debug_mesh.png" title="Debug Mesh" />

## License

VisualDebugger is available under the MIT license. See the LICENSE file for more info.
