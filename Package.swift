// swift-tools-version:5.7

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
            name: "PianoComposer",
            targets: ["PianoComposer"]
        ),
        .library(
            name: "PianoTemplate",
            targets: ["PianoTemplate"]
        ),
    ],
    dependencies: [
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
        /// C1X
    ]
)
