// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "espresso",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Espresso", targets: ["Espresso"])
    ],
    targets: [
        .executableTarget(
            name: "Espresso",
            path: "Sources/Espresso",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("IOKit"),
                .linkedFramework("ServiceManagement")
            ]
        )
    ]
)
