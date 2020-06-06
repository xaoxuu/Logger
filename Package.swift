// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Logger",
    products: [
        .library(name: "Logger", targets: ["Logger"]),
    ],
    targets: [
        .target(
            name: "Logger",
            dependencies: []
        ),
        .testTarget(
            name: "LoggerTests",
            dependencies: ["Logger"]
        ),
    ]
)
