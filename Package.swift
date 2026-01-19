// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pomo",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Pomo",
            dependencies: [],
            path: ".",
            exclude: ["README.md", "GEMINI.md", "LICENSE", ".gitignore", "APP_STORE_GUIDE.md", "Pomo"]
        ),
    ]
)
