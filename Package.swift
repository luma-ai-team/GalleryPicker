// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "GalleryPicker",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "GalleryPicker",
            targets: ["GalleryPicker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/luma-ai-team/PermissionKit", branch: "master"),
        .package(url: "https://github.com/luma-ai-team/CoreUI", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "GalleryPicker",
            dependencies: [.product(name: "CoreUI", package: "CoreUI"),
                           .product(name: "PermissionKit", package: "PermissionKit")
                          ],
            exclude: ["Example"]),
        .testTarget(
            name: "GalleryPickerTests",
            dependencies: ["GalleryPicker"],
            exclude: ["Example"]),
    ]
)
