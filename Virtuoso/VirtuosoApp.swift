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
    @State private var handManager = HandManager()
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
                .environment(playbackManager)
                .environment(pianoManager)
                .modelContainer(DataController.previewContainer)
        }

        // MARK: The floating menu to help configure the virtual piano

        WindowGroup("Piano Configuration Menu", id: Module.pianoConfigurationMenu.name) {
            PianoConfigurationMenu()
                .environment(appState)
                .environment(pianoManager)
        }
        .defaultSize(width: 500, height: 350)
        .onChange(of: appState.showConfigurationMenu) { oldValue, newValue in
            Task {
                print("Responding to showConfigurationMenu change from \(oldValue) to \(newValue)")
                if newValue {
                    openWindow(id: Module.pianoConfigurationMenu.name)
                } else {
                    dismissWindow(id: Module.pianoConfigurationMenu.name)
                }
            }
        }

        ImmersiveSpace(id: Module.immersiveSpace.name) {
            PianoRealityView()
                .environment(appState)
                .environment(pianoManager)
                .environment(handManager)
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
                    appState.returnToBrowser()
                    playbackManager.stopPlayback()
                }
            }
        }
    }
}
