// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "IPTV",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke.git", from: "12.8.0"),
        .package(url: "https://github.com/markiv/SwiftUI-Shimmer.git", from: "1.5.1"),
    ],
    targets: [
        .executableTarget(
            name: "IPTV",
            dependencies: [
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke"),
                .product(name: "Shimmer", package: "SwiftUI-Shimmer"),
            ],
            path: "Sources/IPTV"
        ),
    ]
)
