# Copilot 指南 — VisualDebugger

目的：帮助 AI 编码代理快速上手本仓库，理解关键架构、约定、构建与常见样例。

- **仓库类型**：Swift 多目标包（SPM），同时提供 CocoaPods 支持。主要 targets：`VisualDebugger`, `VisualUtils`（见 `Package.swift`）。
- **主要入口/组件**：
  - `DebugView` / `Sources/VisualDebugger/DebugView.swift`：UI 层，负责平台差异（iOS/macOS）绘制与刷新。
  - `DebugContext` / `Sources/VisualDebugger/DebugContext.swift`：渲染上下文与坐标变换、元素合并、日志渲染逻辑。
  - `DebugManager` / `Sources/VisualDebugger/DebugManager.swift`：全局元素单例，按队列同步追加并在最终渲染时合并。
  - `DebugCapture` / `Sources/VisualDebugger/DebugCapture.swift`：批量截图、写入文件、提供 `shared` 快照流水线（含线程锁保护）。
  - `Debuggable`/`DebugRenderable`/`ContextRenderable` / `Sources/VisualDebugger/Debuggable.swift`：核心协议，定义渲染契约与 `debugElements`/`preferredDebugConfig` 的约定。
  - `Logger` / `Sources/VisualDebugger/debuggers/Logger.swift`：内部日志系统（单例、线程安全），日志渲染为文本元素。

- **重要模式与约定（项目特有）**：
  - 使用 Swift `@resultBuilder`（`DebugBuilder`、`DebugRenderBuilder`、`RenderBuilder`）构造渲染元素。示例见 `algorithms/DebugRenderBuilder.swift`。
  - 渲染元素实现 `ContextRenderable` 或 `DebugRenderable`，并通过 `DebugView(elements:)` 或 `DebugContext(elements:)` 进行绘制。
  - 单例与线程安全：`DebugManager.shared` 和 `Logger.default` 都通过私有队列保证同步；`DebugCapture.shared` 通过 `NSLock` 保护静态共享实例。
  - 坐标系显式支持 `.yDown` / `.yUp`（参见 `coordinateSystem/CoordinateSystem2D.swift`），渲染流程会根据 `coordinateSystem` 做翻转矩阵处理。
  - 平台差异：`DebugView.draw(_:)` 在 iOS 使用 `UIGraphicsGetCurrentContext()`，在 macOS 使用 `NSGraphicsContext.current?.cgContext`；注意 `isFlipped` 在 macOS 的影响。

- **构建 / 测试 / 调试**：
  - Swift Package: `swift build`，`swift test`（在 macOS / CI 环境运行）。
  - Xcode workspace: `open VisualDebugger.xcworkspace`（仓库内包含 workspace 与 Playground 示例）。
  - CocoaPods: 编辑 `Podfile` 后 `pod install`；仓库提供 `VisualDebugger.podspec`，可用 `pod lint` / `pod trunk push`。
  - 运行 Playground: 打开 `VisualDebugger.xcworkspace` 下的 `Playground.playground` 页面，里面有多个演示页面用于快速验证视觉输出。

- **常见开发任务 & 代码示例（可直接用于自动化修改/补全）**：
  - 创建一个简单调试视图：
    - `DebugView { Polygon([...]) }` 或 `DebugView(elements: [myDebugElement])`（参见 `README.md` 示例）。
  - 在算法执行中拍摄快照：创建 `DebugCapture.shared = DebugCapture(context: ctx, folder: url)`，然后调用 `captureElements("step") { Polygon(...) }`，最后 `output()` 写入文件。
  - 自定义元素：实现 `DebugRenderable`，提供 `debugBounds` 与 `render(with:in:scale:contextHeight:)`。

- **代码风格 / 命名约定**：
  - 含平台条件编译（`#if canImport(UIKit)` / `#elseif canImport(AppKit)`）以保持 iOS/macOS 兼容。
  - 使用 `@unchecked Sendable` 在需要时标注类型以跨线程使用（注意确保内部同步）。
  - result-builder 返回数组类型：`BaseBuilder` 提供了多种 `buildBlock`/`buildOptional` 重载，代理应按此模式生成元素集合。

- **注意事项（代理在修改/生成代码时要留意）**：
  - 渲染尺寸由 `DebugContext` 在初始化时计算（基于 `elements.debugBounds`），修改元素集合可能需要同步更新 `DebugView.frame`。
  - 不要移除或更改线程保护（`DispatchQueue`/`NSLock`）否则可能引起并发问题。
  - 在添加依赖或修改 API 时，同步更新 `Package.swift` 与 `VisualDebugger.podspec`。

如果需要，我可以把本文件调整为英文版本，或把更多示例（函数签名和更细的类间调用序列）加入到说明中。请告知哪些部分需要更详细的示例或补充。
