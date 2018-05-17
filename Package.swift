// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "RunnerServer",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.3"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0-rc.2"),

        // FBLogin support.
        .package(url: "https://github.com/stormpath/Turnstile.git", from: "1.0.6"),

        // Auth support.
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc.4.1")

        ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "Turnstile", "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

