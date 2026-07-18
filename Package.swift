// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "IPTV",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "IPTV",
            path: "Sources/IPTV"
        )
    ]
)
