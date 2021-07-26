// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhoAggregateDoseServicesLib",
	platforms: [
		.macOS(.v11)
	],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PhoAggregateDoseServicesLib",
            targets: ["PhoAggregateDoseServicesLib"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/CommanderPho/DoseComputationLib.git", from: "0.1.0"),
		 .package(url: "https://github.com/CommanderPho/PhoAppleNotesFramework.git", from: "2.3.0"),
		 .package(url: "git@github.com:CommanderPho/PhoNotesParser.git", from: "0.3.1"),
	     .package(url: "https://github.com/CommanderPho/PhoCoreEventsLib.git", .upToNextMinor(from: "0.0.7")),
		 .package(url: "https://github.com/CommanderPho/PhoNotesLib.git", from: "0.0.1"),
		 .package(url: "https://github.com/CommanderPho/DoseRecordPersistanceDatasource.git", from: "0.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PhoAggregateDoseServicesLib",
            dependencies: ["DoseComputationLib", "PhoAppleNotesFramework", "PhoNotesParser", "PhoNotesLib", "PhoCoreEventsLib", "DoseRecordPersistanceDatasource"]),
        .testTarget(
            name: "PhoAggregateDoseServicesLibTests",
            dependencies: ["PhoAggregateDoseServicesLib"]),
    ]
)
