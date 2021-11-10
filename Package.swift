// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "PianoSDK",
    platforms: [
        .iOS(.v10),
        .tvOS(.v10)
    ],
    products: [
        .library(
            name: "PianoCommon",
            targets: ["PianoCommon"]
        ),
        .library(
            name: "PianoOAuth",
            targets: ["PianoOAuth"]
        ),
        .library(
            name: "PianoComposer",
            targets: ["PianoComposer"]
        ),
        .library(
            name: "PianoTemplate",
            targets: ["PianoTemplate"]
        ),
       .library(
           name: "PianoC1X",
           targets: ["PianoC1X"]
       )
    ],
    dependencies: [
        .package(name: "GoogleSignIn", url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMinor(from: "6.0.0")),
        .package(name: "Facebook", url: "https://github.com/facebook/facebook-ios-sdk", .upToNextMinor(from: "9.3.0")),
        .package(name: "CxenseSDK", url: "https://github.com/cXense/cxense-spm.git", .upToNextMinor(from: "1.9.7"))
    ],
    targets: [
        /// Common
        .target(
            name: "PianoCommon",
            path: "Common/Sources",
            resources: [
                .process("Resources")
            ]
        ),
        /// OAuth
        .target(
            name: "PianoOAuth",
            dependencies: [
                "PianoCommon",
                "GoogleSignIn",
                .product(name: "FacebookLogin", package: "Facebook")
            ],
            path: "OAuth/Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PianoOAuthTests",
            dependencies: ["PianoOAuth"],
            path: "OAuth/Tests"
        ),
        /// Composer
        .target(
            name: "PianoComposer",
            dependencies: [
                "PianoCommon"
            ],
            path: "Composer/Sources"
        ),
        .testTarget(
            name: "PianoComposerTests",
            dependencies: ["PianoComposer"],
            path: "Composer/Tests"
        ),
        /// Template
        .target(
            name: "PianoTemplate",
            dependencies: [
                "PianoComposer"
            ],
            path: "Template/Sources"
        ),
        .testTarget(
            name: "PianoTemplateTests",
            dependencies: ["PianoTemplate"],
            path: "Template/Tests"
        ),
        /// C1X
        .target(
            name: "PianoC1X",
            dependencies: [
                "PianoComposer",
                "CxenseSDK"
            ],
            path: "C1X/Sources"
        ),
        .testTarget(
            name: "PianoC1XTests",
            dependencies: ["PianoC1X"],
            path: "C1X/Tests"
        ),
    ]
)
