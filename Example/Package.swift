// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Example",
    products: [
        .executable(name: "Example", targets: ["Example"])
    ],
    dependencies: [
        .package(path: "../")
    ],
    targets: [
        .target(name: "Example", dependencies: [.byName(name: "AutomatedBrowser")]),
    ]
)
