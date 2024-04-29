import RealityKit
import RealityKitContent
import SwiftUI

/// A view that manages all the entities for the piano experience
/// World interactions are managed here and updates are passed down to the entities
struct PianoRealityView: View {
    @Environment(AppState.self) var appState
    @Environment(WorldManager.self) var worldManager
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
            await worldManager.startARKitSession()
        }

        .task {
            await worldManager.monitorSessionEvents()
        }

        .task {
            await worldManager.handleHandTrackingUpdates()
        }

        .task {
            // TODO: should this really be async?
            guard let selectedSong = appState.selectedSong else { return }

            // TODO: add some protection to loadSong to ensure all the resources are loaded
            await playbackManager.loadSong(selectedSong)
        }

        // TODO: BIG: Consider rewriting this whole idea as a system or component
        // TODO: it seems weird that we listen to this var instead of the current timestamp
        // TODO: should we just publish that instead of the target display timestamp?
        .onChange(of: playbackManager.targetDisplayTimestamp) { _, _ in
            guard let sequencer = playbackManager.sequencer else { return }
            for track in playbackManager.lessonTracks {
                guard let midiTrack = playbackManager.sequence?.tracks[track.trackNumber] else { continue }

                // TODO: need to calculate the diff by the time you get here
                // TODO: by the time you get to the second track, we could be a little off
                pianoManager.drawTrack(track: midiTrack, targetTimestamp: sequencer.currentTimeStamp, color: track.hand == .left ? .systemGreen : .systemBlue)
            }
        }
        .onAppear {
            appState.immersiveSpaceIsShown = true
        }

        // TODO: This might not really be working
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
            .environment(WorldManager())
            .environment(PlaybackManager())
            .onAppear {
                pianoManager.repositionAnchors(leftPosition: [-1, 0, 0], rightPosition: [1, 0, 0])
            }
    }
}
