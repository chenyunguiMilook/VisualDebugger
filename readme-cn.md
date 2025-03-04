---
typora-root-url: ./Images
---

# VisualDebugger

最优雅、最简单的方式在源文件中可视化您的数据

## 功能特点

- [x] 支持多种坐标系统（yUp, yDown）
- [x] 支持可视化调试Mesh网格结构
- [x] 支持可视化调试点集（Points）及样式定制
- [x] 支持可视化调试贝塞尔路径
- [x] 支持iOS和macOS平台
- [x] 灵活的样式定制系统
- [x] 详细的坐标轴显示和标注

## 系统要求

- iOS 17.0+ | macOS 15+
- Swift 6.0+
- Xcode 16+

## 安装方法

#### Swift Package Manager

您可以使用[Swift Package Manager](https://swift.org/package-manager)安装`VisualDebugger`，只需将其添加到您的`Package.swift`文件中：

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

## 使用示例

### 调试点集

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



![](/debug_points.png)



### 调试网格结构

```swift
#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    // 示例：创建一个简单的三角形网格
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
            .overrideVertexStyle(at: 1, color: .red, name: .string("顶点1"))
            .overrideEdgeStyle(for: .init(org: 2, dst: 1), color: .green)
            .overrideFaceStyle(at: 0, color: .blue, alpha: 0.2)
            .setDisplay(vertices: true, edges: true, faces: true)
    ], showOrigin: true, coordinateSystem: .yDown)
}
```

### ![](/debug_mesh.png)

## 许可证

VisualDebugger 使用 MIT 许可证。详情请参阅 LICENSE 文件。
