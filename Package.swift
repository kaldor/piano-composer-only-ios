// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "PianoSDK",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12)
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
            name: "PianoTemplate.ID",
            targets: ["PianoTemplate.ID"]
        ),
       .library(
           name: "PianoC1X",
           targets: ["PianoC1X"]
       )
    ],
    dependencies: [
        .package(name: "GoogleSignIn", url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMinor(from: "6.2.4")),
        .package(name: "Facebook", url: "https://github.com/facebook/facebook-ios-sdk", .upToNextMinor(from: "15.1.0")),
        .package(name: "CxenseSDK", url: "https://github.com/cXense/cxense-spm.git", .upToNextMinor(from: "1.9.11"))
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
            path: "Template/Core/Sources"
        ),
        .testTarget(
            name: "PianoTemplateTests",
            dependencies: ["PianoTemplate"],
            path: "Template/Core/Tests"
        ),
        /// Template.ID
        .target(
            name: "PianoTemplate.ID",
            dependencies: [
                "PianoOAuth",
                "PianoTemplate"
            ],
            path: "Template/ID/Sources"
        ),
        .testTarget(
            name: "PianoTemplateIDTests",
            dependencies: ["PianoTemplate.ID"],
            path: "Template/ID/Tests"
        ),
        /// C1X
        .target(
            name: "PianoC1X",
            dependencies: [
                "PianoComposer",
                "PianoTemplate",
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
