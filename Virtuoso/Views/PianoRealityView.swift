import RealityKit
import RealityKitContent
import SwiftUI

/// A view that manages all the entities for the piano experience
/// World interactions are managed here and updates are passed down to the entities
struct PianoRealityView: View {
    let appState: AppState
    let handManager: HandManager

    @State private var playbackManager = PlaybackManager()

    var body: some View {
        RealityView { content, attachments in
            if let playbackAttachment = attachments.entity(for: PlaybackWidget.attachmentId) {
                playbackAttachment.scale = [0.3, 0.3, 0.3]
                playbackAttachment.position = [0, 0, -0.5]
                playbackAttachment.transform.rotation = simd_quatf(angle: -.pi / 4, axis: [1, 0, 0])
                centerAnchor.addChild(playbackAttachment)
            } else {
                assertionFailure("sceneAttachment is undefined")
            }

            // Load everything in
            content.add(spaceOrigin)

            // Load peg!
            playbackManager.loadPeg()
        }

        attachments: {
            Attachment(id: PlaybackWidget.attachmentId) {
                PlaybackWidget().glassBackgroundEffect()
            }
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
