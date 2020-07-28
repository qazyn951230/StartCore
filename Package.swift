// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "StartPoint",
    platforms: [.macOS(.v10_14), .iOS(.v10)],
    products: [
        .library(name: "StartCore", targets: ["StartCore"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Core",
            dependencies: [],
            cxxSettings: [.unsafeFlags(["-std=c++17"])]),
        .target(
            name: "StartCore",
            dependencies: ["Core"]),
        .testTarget(
            name: "StartCoreTests",
            dependencies: ["StartCore"])),
    ]
)
