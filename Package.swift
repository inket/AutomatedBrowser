// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AutomatedBrowser",
    products: [
        .library(name: "AutomatedBrowser", targets: ["AutomatedBrowser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pvieito/PythonKit.git", from: "0.3.1"),
    ],
    targets: [
        .target(name: "AutomatedBrowser", dependencies: [.byName(name: "PythonKit")]),
    ]
)
