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
            BrowserView()
                .environment(appState)
                .modelContainer(DataController.previewContainer)
        }
        .onChange(of: appState.showBrowserWindow) { _, newValue in
            Task {
                if newValue {
                    openWindow(id: Module.browser.name)
                } else {
                    dismissWindow(id: Module.browser.name)
                }
            }
        }

        // MARK: The floating menu to help configure the virtual piano

        WindowGroup("Piano Configuration Menu", id: Module.pianoConfigurationMenu.name) {
            PianoConfigurationMenu()
                .environment(appState)
                .environment(pianoManager)
        }
        .defaultSize(width: 500, height: 350)
        .onChange(of: appState.showConfigurationMenu) { _, newValue in
            Task {
                if newValue {
                    openWindow(id: Module.pianoConfigurationMenu.name)
                } else {
                    dismissWindow(id: Module.pianoConfigurationMenu.name)
                }
            }
        }

        // MARK: The main trainer view which is the immersive space, and the window

        WindowGroup("Trainer", id: Module.trainer.name) {
            TrainerView()
                .environment(appState)
                .environment(playbackManager)
        }
        .onChange(of: appState.showTrainerWindow) { _, newValue in
            Task {
                if newValue {
                    openWindow(id: Module.trainer.name)
                } else {
                    dismissWindow(id: Module.trainer.name)

                    appState.showImmersiveSpace = false
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
        .onChange(of: appState.showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: Module.immersiveSpace.name) {
                    case .opened:
                        appState.showConfigurationMenu = true
                        appState.showTrainerWindow = true

                        appState.showBrowserWindow = false
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        appState.immersiveSpaceIsShown = false
                        appState.showImmersiveSpace = false
                    }
                } else if appState.immersiveSpaceIsShown {
                    await dismissImmersiveSpace()

                    // TODO: replace all these calls with a shared toggle method on the app state
                    appState.showTrainerWindow = false
                    appState.showConfigurationMenu = false
                    appState.showBrowserWindow = true
                }
            }
        }
    }
}
