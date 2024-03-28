import RealityKit
import RealityKitContent
import SwiftUI

/// A view that manages all the entities for the piano experience
/// World interactions are managed here and updates are passed down to the entities
struct PianoRealityView: View {
    @Environment(AppState.self) var appState
    @Environment(HandManager.self) var handManager
    @Environment(PianoManager.self) var pianoManager
    @Environment(PlaybackManager.self) var playbackManager

    var body: some View {
        RealityView { content in
            // Load everything in
            // TODO: this might be causing pop-in because things load asynchronously
            content.add(spaceOrigin)
            content.add(pianoAnchor)
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

        // TODO: should we just be using the targetDisplayTimestamp?
        .onChange(of: playbackManager.targetDisplayTimestamp) { _, _ in
            guard let track = playbackManager.sequence?.tracks[1],
                  let sequencer = playbackManager.sequencer else { return }

            pianoManager.drawTrack(track: track, targetTimestamp: sequencer.currentTimeStamp)
        }

        .onAppear {
            appState.immersiveSpaceIsShown = true
        }

        .onDisappear {
            appState.immersiveSpaceIsShown = false
        }
    }
}

struct PianoRealityView_Previews: PreviewProvider {
    static let pianoManager = PianoManager()

    static var previews: some View {
        PianoRealityView()
            .environment(AppState())
            .environment(pianoManager)
            .environment(HandManager())
            .environment(PlaybackManager())
            .onAppear {
                pianoManager.repositionAnchors(leftPosition: [-1, 0, 0], rightPosition: [1, 0, 0])
            }
    }
}
