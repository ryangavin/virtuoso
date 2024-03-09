import RealityKit
import RealityKitContent
import SwiftUI

/// A view that manages all the entities for the piano experience
/// World interactions are managed here and updates are passed down to the entities
struct PianoRealityView: View {
    @Environment(AppState.self) var appState
    @Environment(HandManager.self) var handManager
    @Environment(PlaybackManager.self) var playbackManager

    var body: some View {
        RealityView { content in
            // Load everything in
            // TODO: this might be causing pop-in because things load asynchronously
            content.add(spaceOrigin)
        }

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

        .task {
            await playbackManager.loadSequence()
        }

        .onChange(of: playbackManager.targetDisplayTimestamp) { _, _ in
            guard let track = playbackManager.sequence?.tracks[1],
                  let sequencer = playbackManager.sequencer else { return }
            appState.drawTrack(track: track, targetTimestamp: sequencer.currentTimeStamp)
        }
    }
}

struct PianoRealityView_Previews: PreviewProvider {
    static let appState = AppState()

    static var previews: some View {
        PianoRealityView()
            .environment(appState)
            .environment(HandManager())
            .environment(PlaybackManager())
            .onAppear {
                appState.repositionAnchors(leftPosition: [1, 0, 0], rightPosition: [1, 0, 0])
            }
    }
}
