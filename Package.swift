// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Wampproto",
    products: [
        .library(
            name: "Wampproto",
            targets: ["Wampproto"])
    ],
    dependencies: [
        .package(url: "https://github.com/malcommac/SwiftMsgPack.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "Wampproto",
            dependencies: ["SwiftMsgPack"]
        ),
        .testTarget(
            name: "WampprotoTests",
            dependencies: ["Wampproto"])
    ]
)
