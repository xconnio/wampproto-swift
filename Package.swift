// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Wampproto",
    products: [
        .library(
            name: "Wampproto",
            targets: ["Wampproto"])
    ],
    targets: [
        .target(
            name: "Wampproto"),
        .testTarget(
            name: "WampprotoTests",
            dependencies: ["Wampproto"])
    ]
)
