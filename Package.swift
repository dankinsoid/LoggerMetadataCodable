// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoggerMetadataCodable",
    products: [
        .library(name: "LoggerMetadataCodable", targets: ["LoggerMetadataCodable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.1"),
        .package(url: "https://github.com/dankinsoid/SimpleCoders.git", from: "1.4.0")
    ],
    targets: [
        .target(
            name: "LoggerMetadataCodable",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                "SimpleCoders"
            ]
        )
    ]
)
