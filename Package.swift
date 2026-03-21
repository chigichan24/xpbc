// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "xpbc",
    platforms: [
        .macOS(.v13),
    ],
    targets: [
        .target(
            name: "XPBCCore",
            path: "Sources/XPBCCore"
        ),
        .executableTarget(
            name: "xpbc",
            dependencies: ["XPBCCore"],
            path: "Sources/xpbc"
        ),
        .testTarget(
            name: "XPBCCoreTests",
            dependencies: ["XPBCCore"],
            path: "Tests/XPBCCoreTests"
        ),
    ]
)
