// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Onward",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Onward",
            targets: ["Onward"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "4.43.0")
    ],
    targets: [
        .target(
            name: "Onward",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios")
            ]
        ),
    ]
) 