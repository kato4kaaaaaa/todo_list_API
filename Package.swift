// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "TodoAPI",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.83.1"),
        // 🗄 An ORM for Swift and Vapor.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        // 🐘 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.7.2"),
        // 🔵 Non-blocking, event-driven networking for Swift.
        // .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
    ],
    // ...
        targets: [
            .executableTarget(
                name: "App",
                dependencies: [
                    .product(name: "Fluent", package: "fluent"),
                    .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                    .product(name: "Vapor", package: "vapor"),
                ],
                path: "Sources/App",
                swiftSettings: swiftSettings
            ),
            .testTarget(
                name: "TodoAPITests",
                dependencies: [
                    .target(name: "App"),
                    .product(name: "VaporTesting", package: "vapor"),
                ],
                path: "Tests/TodoAPITests",
                swiftSettings: swiftSettings
            )
        ]
    
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
