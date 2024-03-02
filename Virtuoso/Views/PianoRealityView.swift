import RealityKit
import RealityKitContent
import SwiftUI

/// A view that manages all the entities for the piano experience
/// World interactions are managed here and updates are passed down to the entities
struct PianoRealityView: View {
    let appState: AppState
    let handManager: HandManager

    var body: some View {
        RealityView { content in
            // Load everything in
            content.add(spaceOrigin)
        }

        .upperLimbVisibility(.hidden)

        // MARK: Background Tasks

        .task {
            await handManager.startARKitSession()
        }

        .task {
            await handManager.monitorSessionEvents()
        }

        .task {
            await handManager.handleHandTrackingUpdates()
        }
    }
}
