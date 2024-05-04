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

    @MainActor
    func drawTrack(currentTime: Double) {
        guard playbackManager.sequencer != nil else { return }
        for track in playbackManager.lessonTracks {
            guard let midiTrack = playbackManager.sequence?.tracks[track.trackNumber] else { continue }

            // TODO: need to calculate the diff by the time you get here
            // TODO: by the time you get to the second track, we could be a little off
            pianoManager.drawTrack(track: midiTrack, targetTimestamp: currentTime, color: track.hand == .left ? .systemGreen : .systemBlue)
        }
    }

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

        .onChange(of: appState.loadedSong) {
            // TODO: should this really be async?
            guard let loadedSong = appState.loadedSong else {
                print("Tried to load a song, but there was no song loaded!")
                return
            }

            // TODO: add some protection to loadSong to ensure all the resources are loaded
            appState.showLoadingView = true
            pianoManager.clearTrack()
            playbackManager.loadSong(loadedSong)
            drawTrack(currentTime: 0)
            appState.showLoadingView = false
        }

        // TODO: BIG: Consider rewriting this whole idea as a system or component
        // TODO: it seems weird that we listen to this var instead of the current timestamp
        // TODO: should we just publish that instead of the target display timestamp?
        .onChange(of: playbackManager.currentTime) { _, currentTime in
            drawTrack(currentTime: currentTime)
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
