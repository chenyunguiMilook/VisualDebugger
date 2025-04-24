// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VisualDebugger",
    platforms: [
        .macOS(.v15),
        .iOS(.v17),
        .macCatalyst(.v17)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "VisualDebugger",
            targets: ["VisualDebugger"]),
        .library(
            name: "VisualUtils",
            targets: ["VisualUtils"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "VisualUtils"),
        .target(
            name: "VisualDebugger",
            dependencies: ["VisualUtils"]),
        .testTarget(
            name: "VisualDebuggerTests",
            dependencies: ["VisualDebugger"]),
    ]
)
