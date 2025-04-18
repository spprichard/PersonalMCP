// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "API",
    platforms: [
        .macOS(.v14)
    ],
     products: [
        .library(
            name: "EmailAPI",
            targets: [
                "EmailAPI"
            ]
        ),
        .library(
            name: "OcrAPI",
            targets: [
                "OcrAPI"
            ]
        )
     ],
    dependencies: [
        // 🚜 API
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        // .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.9.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-async-http-client", from: "1.0.0"),
        // 🤖 SwiftMCP
        .package(url: "https://github.com/Cocoanetics/SwiftMCP", branch: "main"),
        // ✉️ Email
        // NOTE: Swift-NIO-IMAP got updated, causing a crash. Switching to local copy of SwiftMail,
        // where Swift-NIO-IMAP is pinned to working version
        // .package(url: "https://github.com/Cocoanetics/SwiftMail", branch: "main"),
        .package(path: "../SwiftMail"),
        .package(url: "https://github.com/thebarndog/swift-dotenv", from: "2.1.0"),
        // 🌐 OpenAPI
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.6.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.7.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-hummingbird", from: "2.0.1"),
        // 🇫🇷 MistralKit 🦾
        .package(url: "https://github.com/vapor/multipart-kit", from: "4.0.0"),
        .package(url: "https://github.com/swift-extras/swift-extras-base64", .upToNextMinor(from: "0.7.0")),
    ],
    targets: [
        .executableTarget(
            name: "API",
            dependencies: [
                .byName(name: "EmailAPI"),
                .byName(name: "OcrAPI"),
                .product(name: "SwiftMCP", package: "SwiftMCP"),
//                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
        ),
//        .executableTarget(
//            name: "MCP",
//            dependencies: [
//                .byName(name: "Spec"),
//                .byName(name: "EmailAPI"),
//                .byName(name: "OcrAPI"),
//                .product(name: "SwiftMCP", package: "SwiftMCP"),
//                .product(name: "ArgumentParser", package: "swift-argument-parser"),
//            ],
//        ),
        .target(
            name: "EmailAPI",
            dependencies: [
                .product(name: "SwiftMail", package: "SwiftMail"),
                .product(name: "SwiftDotenv", package: "swift-dotenv"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIHummingbird", package: "swift-openapi-hummingbird"),
                .product(name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
            ],
            plugins: [
                .plugin(
                    name: "OpenAPIGenerator",
                    package: "swift-openapi-generator"
                )
            ]
        ),
        .target(
            name: "OcrAPI",
            dependencies: [
                .byName(name: "EmailAPI"),
                .product(name: "SwiftDotenv", package: "swift-dotenv"),
                .product(name: "MultipartKit", package: "multipart-kit"),
                .product(name: "ExtrasBase64", package: "swift-extras-base64"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIHummingbird", package: "swift-openapi-hummingbird"),
                .product(name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
            ],
            plugins: [.plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")]
        ),
    ]
)
