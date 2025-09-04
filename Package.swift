// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Wampproto",
    platforms: [
        .macOS(.v13), // Requires macOS 13 or newer
        .iOS(.v13), // Requires iOS 13 or newer
        .tvOS(.v13), // Requires tvOS 13 or newer
        .watchOS(.v6) // Requires watchOS 6 or newer,
    ],
    products: [
        .library(
            name: "Wampproto",
            targets: ["Wampproto"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/fumoboy007/msgpack-swift.git", from: "2.0.6"),
        .package(url: "https://github.com/myfreeweb/SwiftCBOR.git", from: "0.5.0"),
        .package(url: "https://github.com/jedisct1/swift-sodium.git", from: "0.9.1")
    ],
    targets: [
        .target(
            name: "Wampproto",
            dependencies: [
                "SwiftCBOR",
                .product(name: "DMMessagePack", package: "msgpack-swift"),
                .product(name: "Sodium", package: "swift-sodium")
            ]
        ),
        .testTarget(
            name: "WampprotoTests",
            dependencies: ["Wampproto"]
        )
    ]
)
