// swift-tools-version:5.2

import PackageDescription

let enablePerformanceTests = false
let enableBundleTests = false

let package = Package(
    name: "StartCore",
    platforms: [.macOS(.v10_14), .iOS(.v10)],
    products: [
        .library(name: "StartCore", targets: ["StartCore"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Core",
            dependencies: [],
            cxxSettings: [
                .unsafeFlags(["-std=c++17"]),
                .define("SP_CPP_USE_NAMESPACE"),
                .define("SP_CPP_NAMESPACE", to: "StartPoint"),
            ]
        ),
        .target(
            name: "StartCore",
            dependencies: ["Core"]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            swiftSettings: [
                .define(enablePerformanceTests ? "ENABLE_PERFORMANCE_TESTS" : "DISABLE_PERFORMANCE_TESTS"),
                .define(enableBundleTests ? "ENABLE_BUNDLE_TESTS" : "DISABLE_BUNDLE_TESTS"),
            ]
        ),
        .testTarget(
            name: "StartCoreTests",
            dependencies: ["StartCore"],
            swiftSettings: [
                .define(enablePerformanceTests ? "ENABLE_PERFORMANCE_TESTS" : "DISABLE_PERFORMANCE_TESTS"),
                .define(enableBundleTests ? "ENABLE_BUNDLE_TESTS" : "DISABLE_BUNDLE_TESTS"),
            ]
        ),
    ]
)
