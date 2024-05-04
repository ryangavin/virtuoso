import RealityKit
import RealityKitContent
import SwiftUI

/**
 The actual AR experience.

 This View is responsible for glueing all the systems together.
 It listens for changes in the app state and updates the world accordingly.
 */
struct PianoRealityView: View {
    @Environment(AppState.self) var appState
    @Environment(WorldManager.self) var worldManager
    @Environment(PianoManager.self) var pianoManager
    @Environment(PlaybackManager.self) var playbackManager

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
        .onChange(of: playbackManager.currentTime) { previousTime, currentTime in
            // If we move backwards in time, we should clear the track
            // This could probably be done in a better way
            if previousTime > currentTime {
                pianoManager.clearTrack()
            }

            // Always draw the track based on where we are
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
