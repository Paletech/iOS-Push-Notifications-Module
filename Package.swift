// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOS-Push-Notifications-Module",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "PushNotification",
            targets: ["PushNotification"]),
    ],
    dependencies: [
        .package(url: "git@github.com:Paletech/iOS-Network-Layer.git", from: "1.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.6.0")),
    ],
    targets: [
        .target(
            name: "PushNotification",
            dependencies: [
                .product(name: "Network", package: "iOS-Network-Layer"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "NetworkInterface", package: "iOS-Network-Layer"),
            ]),
    ]
)
