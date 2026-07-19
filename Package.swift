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
        .package(url: "https://github.com/EmergeTools/Pow.git", from: "1.0.6"),
    ],
    targets: [
        .executableTarget(
            name: "IPTV",
            dependencies: [
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke"),
                .product(name: "Shimmer", package: "SwiftUI-Shimmer"),
                .product(name: "Pow", package: "Pow"),
            ],
            path: "Sources/IPTV",
            linkerSettings: [
                // Embed Info.plist into the binary's __TEXT,__info_plist section so the
                // bare executable that `swift run` launches still has a bundle identity —
                // without one, macOS silently refuses window-manager fullscreen (green
                // button, Cmd+Ctrl+F, toggleFullScreen all no-op).
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Supporting/Info.plist",
                ]),
            ]
        ),
    ]
)
