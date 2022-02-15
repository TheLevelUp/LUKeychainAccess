// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LUKeychainAccess",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "LUKeychainAccess",
            targets: ["LUKeychainAccess"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "LUKeychainAccess",
            dependencies: [],
            exclude: ["LUKeychainAccess-Prefix.pch", "Info.plist"]
        )
    ]
)
