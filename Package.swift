// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorWidgetImageStore",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapacitorWidgetImageStore",
            targets: ["WidgetImageStorePlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "WidgetImageStorePlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/WidgetImageStorePlugin"),
        .testTarget(
            name: "WidgetImageStorePluginTests",
            dependencies: ["WidgetImageStorePlugin"],
            path: "ios/Tests/WidgetImageStorePluginTests")
    ]
)
