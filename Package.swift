// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Logger",
    platforms: [.iOS(.v8)],
    products: [
        .library(name: "Logger", targets: ["Logger"]),
    ],
    targets: [
        .target(
            name: "Logger",
            dependencies: [],
            path: "Source"
        )
    ],
    swiftLanguageVersions: [.v5]
)
