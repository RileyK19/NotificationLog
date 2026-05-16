// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NotificationLog",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "NotificationLog",
            targets: ["NotificationLog"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NotificationLog",
            dependencies: []
        ),
    ]
)
