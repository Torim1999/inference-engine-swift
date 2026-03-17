
// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InferenceEngineSwift",
    platforms: [
        .macOS(.v12), .iOS(.v15)
    ],
    products: [
        .library(name: "InferenceEngineSwift", targets: ["InferenceEngineSwift"]),
    ],
    dependencies: [
        // Dependencies can be added here if needed, e.g., for logging or utility functions
    ],
    targets: [
        .target(
            name: "InferenceEngineSwift",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "InferenceEngineSwiftTests",
            dependencies: ["InferenceEngineSwift"],
            path: "Tests"),
    ]
)
