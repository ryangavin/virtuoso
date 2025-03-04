//
//  VirtuosoApp.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/15/24.
//

import SwiftData
import SwiftUI

@main
struct VirtuosoApp: App {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    @Environment(\.scenePhase) var scenePhase

    @State private var appState = AppState()
    @State private var configurationManager = ConfigurationManager()
    
    @State private var worldManager = WorldManager()
    @State private var pianoManager = PianoManager()
    @State private var playbackManager = PlaybackManager()

    @State private var immersionStyle: ImmersionStyle = .mixed

    init() {
        print("Starting up!")
    }

    var body: some Scene {
        // MARK: The main menu, which is a browser for selecting songs

        WindowGroup("Browser", id: Module.browser.name) {
            LibraryView()
                .environment(appState)
                .environment(configurationManager)
                .environment(playbackManager)
                .environment(pianoManager)
                .modelContainer(DataController.previewContainer)
        }

        ImmersiveSpace(id: Module.immersiveSpace.name) {
            PianoRealityView()
                .environment(appState)
                .environment(pianoManager)
                .environment(worldManager)
                .environment(playbackManager)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed)
        .onChange(of: appState.showImmersiveSpace) { oldValue, newValue in
            Task {
                print("Responding to showImmersiveSpace change from \(oldValue) to \(newValue)")
                if newValue {
                    print("Opening immersive space")
                    switch await openImmersiveSpace(id: Module.immersiveSpace.name) {
                    case .opened:
                        // immersiveSpaceIsShown is updated by the actual view
                        print("Immersive space opened")
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        appState.immersiveSpaceIsShown = false
                        appState.showImmersiveSpace = false
                    }
                } else if appState.immersiveSpaceIsShown {
                    print("Dismissing immersive space")
                    await dismissImmersiveSpace()
                }
            }
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            print("Scene phase changed from \(oldValue) to \(newValue)")
            if appState.immersiveSpaceIsShown && newValue == .background {
                Task {
                    print("Dismissing immersive space due to scene phase change")
                    await dismissImmersiveSpace()
                    playbackManager.stopPlayback()
                }
            }
        }
    }
}
