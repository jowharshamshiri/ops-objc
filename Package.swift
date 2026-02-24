// version: 0.5.3990
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ops-objc",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "Ops",
            targets: ["Ops"]
        ),
    ],
    targets: [
        .target(
            name: "Ops",
            path: "Sources/Ops"
        ),
        .testTarget(
            name: "OpsTests",
            dependencies: ["Ops"],
            path: "Tests/OpsTests"
        ),
    ]
)
