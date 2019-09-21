// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "ConnectionKit",
    platforms: [
        .iOS(.v8), .tvOS(.v9), .macOS(.v10_11), .watchOS(.v3)
    ],
    products: [
        .library(name: "ConnectionKit", targets: ["ConnectionKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        .target(name: "ConnectionKit", dependencies: ["RxSwift", "RxCocoa"], path: "Source"),
    ],
    swiftLanguageVersions: [.v5]
)
