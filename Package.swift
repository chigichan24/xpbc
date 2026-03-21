// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "xpbc",
    platforms: [
        .macOS(.v13),
    ],
    targets: [
        .executableTarget(
            name: "xpbc",
            path: "Sources/xpbc"
        ),
    ]
)
