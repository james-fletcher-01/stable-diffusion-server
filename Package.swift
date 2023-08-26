// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "stable-diffusion-server",
	platforms: [
		.macOS("13.1")
	],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
		.package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.0.0-alpha.1"),
		.package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
		.package(url: "https://github.com/sushichop/Puppy.git", from: "0.7.0"),
		.package(url: "https://github.com/apple/swift-nio.git", from: "2.58.0"),
		// At the time of writing, the last official release of ml-stable-diffusion is 1.0.0.
		// This version requires macOS 14, which is still in beta.
		// The latest development build contains compiler directives to restore support with older versions.
		// This should be updated to use an official release once the next one is avaialble.
		.package(url: "https://github.com/apple/ml-stable-diffusion.git", revision: "b392a0aca09a8321c8955ee84b48e9e9fdb49c93")
    ],
    targets: [
        .executableTarget(
            name: "StableDiffusionServer",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
				.product(name: "Logging", package: "swift-log"),
				.product(name: "Puppy", package: "Puppy"),
				.product(name: "NIO", package: "swift-nio"),
				.product(name: "StableDiffusion", package: "ml-stable-diffusion"),
            ],
			path: "Sources"
		)
    ]
)
