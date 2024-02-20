//
//  ViewModel.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/15/24.
//

import ARKit
import RealityKit
import RealityKitContent
import SwiftUI

/// Holds the global runtime state
/// These values are shared between different views
/// Some views need to react to changes
/// Some views need to make changes
@MainActor class AppModel: ObservableObject {
    // Data providers for ARKit
    // Gets us hand and world data
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()
    private let sceneReconstruction = SceneReconstructionProvider()

    @Published var showImmersiveSpace = false
    @Published var immersiveSpaceIsShown = false
    @Published var showConfigurationMenu = false

    // Piano Configuration
    @Published var shouldShowConfigurtionAnchors = false

    /// Preload assets when the app launches to avoid pop-in during the game.
    init() {
        Task { @MainActor in
            do {
                let anchorAsset = try await Entity(named: "ConfigurationAnchor", in: realityKitContentBundle)
                leftAnchor = anchorAsset
                leftAnchor.name = "Left Anchor"
                leftAnchor.position = .init(-1.0, 1, 1)

                rightAnchor = leftAnchor.clone(recursive: true)
                rightAnchor.name = "Right Anchor"
                rightAnchor.position = .init(1.0, 1, 1)
            } catch {
                print("Error loading: \(error.localizedDescription)")
            }
        }
    }

    func startARKitSession() async {
        do {
            if HandTrackingProvider.isSupported && SceneReconstructionProvider.isSupported {
                print("ARKitSession starting.")
                try await session.run([handTracking, sceneReconstruction])
            }
        } catch {
            print("ARKitSession error:", error)
        }
    }
}
