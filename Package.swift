// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NoContactTracker",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NoContactTracker",
            targets: ["NoContactTracker"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "NoContactTracker",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios")
            ]
        ),
    ]
) 