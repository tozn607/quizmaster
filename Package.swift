// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QuizMaster",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "QuizMaster",
            targets: ["QuizMaster"]
        )
    ],
    targets: [
        .executableTarget(
            name: "QuizMaster",
            path: "Sources/QuizMaster"
        )
    ]
)
