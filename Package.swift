// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppGramSDK",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "AppGramSDK", targets: ["AppGramSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(name: "AppGramSDK", dependencies: [
            .product(name: "MarkdownUI", package: "swift-markdown-ui")
        ]),
        .testTarget(name: "AppGramSDKTests", dependencies: ["AppGramSDK"])
    ]
)
