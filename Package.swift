// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "RunnerServer",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.3"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc.2.3"),
        .package(url: "https://github.com/stormpath/Turnstile.git", from: "1.0.6"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc.4.1")

        ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "Turnstile", "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

