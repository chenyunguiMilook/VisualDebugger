# VisualDebugger — 平台无关的视觉调试系统

本技能涵盖了 `VisualDebugger` 框架的核心渲染与快照捕获逻辑，支持在 iOS、macOS 和 Mac Catalyst 上进行实时的几何与日志可视化调试。

## 核心职责

1. **渲染元素构建**：
   - 使用 `@resultBuilder` (如 `DebugRenderBuilder`) 声明式构建调试元素。
   - 实现 `DebugRenderable` 协议，提供 `debugBounds` 和 `render` 方法。

2. **上下文管理 (DebugContext)**：
   - 管理坐标系转换（`.yUp` 与 `.yDown`）。
   - 计算合并后的包围盒（`debugBounds`）。
   - 处理日志输出的排版渲染。

3. **流程抓取 (DebugCapture)**：
   - 在算法执行的关键步骤调用 `captureElements`。
   - 管理快照序列并将其导出为文件。

4. **平台适配**：
   - 处理 `CGContext` 在 `UIKit` 和 `AppKit` 下的翻转与状态转换。

## 关键流程

### 1. 声明式调试视图
```swift
let view = DebugView {
    Circle(center: .zero, radius: 10)
    Polygon([p1, p2, p3])
    Logger.default.info("Debug initialized")
}
```

### 2. 手动渲染到 Context
```swift
let context = DebugContext(elements: elements)
context.render(in: cgContext, rect: bounds)
```

## 注意事项

- **线程安全**：`DebugManager` 和 `Logger` 内部使用隔离队列。在扩展渲染逻辑时，确保不阻塞主线程，同时在 `DebugView` 刷新时保持同步。
- **坐标系**：VectorShop 核心通常使用 `.yDown`。确保调试输出的坐标系与被调试对象一致，否则会导致视觉反转。
- **性能**：避免在每一帧渲染中重新构建复杂的 `DebugContext`；优先复用元素集合。

## 常用命令

- **构建**: `swift build`
- **Mac Catalyst 构建**: `xcodebuild -scheme "VisualDebugger" -destination "generic/platform=macOS,variant=Mac Catalyst" build`
- **测试**: `swift test`
