// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Virtuoso",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .(
            name: "Virtuoso",
            targets: ["Virtuoso"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/orchetect/MIDIKit.git", from: "0.9.5"),
        .package(url: "https://github.com/matsune/MidiParser.git", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RealityKitContent",
            dependencies: [
                .product(name: "MIDIKit", package: "midikit"),
                .product(name: "MidiParser", package: "midiparser"),
            ]),
    ])
