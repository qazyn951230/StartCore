// swift-tools-version:5.2

import Darwin.C
import PackageDescription

let performanceTests: SwiftSetting = .define(
    environment("START_CORE_PERFORMANCE_TESTS", default: false) ?
        "ENABLE_PERFORMANCE_TESTS" :
        "DISABLE_PERFORMANCE_TESTS")

let bundleTests: SwiftSetting = .define(
    environment("START_CORE_BUNDLE_TESTS", default: false) ?
        "ENABLE_BUNDLE_TESTS" :
        "DISABLE_BUNDLE_TESTS")

let foundationIntegration = environment("START_CORE_FOUNDATION_INTEGRATION", default: true) ?
    "ENABLE_FOUNDATION_INTEGRATION" :
    "DISABLE_FOUNDATION_INTEGRATION"

let swiftFoundation: SwiftSetting = .define(foundationIntegration)
let cxxFoundation: CXXSetting = .define(foundationIntegration)

let cxxSettings: [CXXSetting] = [
    .define("SP_CPP_USE_NAMESPACE"),
    .define("SP_CPP_NAMESPACE", to: "StartPoint"),
    cxxFoundation
]

let swiftSettings: [SwiftSetting] = [
    performanceTests,
    bundleTests,
    swiftFoundation
]

let package = Package(
    name: "StartCore",
    platforms: [.macOS(.v10_14), .iOS(.v10)],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "StartCore", targets: ["StartCore"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Core",
            dependencies: [],
            cxxSettings: cxxSettings
        ),
        .target(
            name: "StartCore",
            dependencies: ["Core"]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "StartCoreTests",
            dependencies: ["StartCore"],
            swiftSettings: swiftSettings
        ),
    ],
    cLanguageStandard: .c11,
    cxxLanguageStandard: .cxx1z
)

func environment(_ name: UnsafePointer<Int8>, default: Bool = false) -> Bool {
    guard let raw = getenv(name) else {
        return `default`
    }
    let result = String(cString: UnsafePointer(raw))
    switch result {
    case "YES", "TRUE", "true", "1":
        return true
    case "NO", "FALSE", "false", "0":
        return false
    case "":
        fallthrough
    default:
        return `default`
    }
}
