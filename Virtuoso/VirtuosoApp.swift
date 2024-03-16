//
//  VirtuosoApp.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/15/24.
//

import SwiftUI

@main
struct VirtuosoApp: App {
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
        }

        // MARK: The floating menu to help configure the virtual piano

        WindowGroup("Piano Configuration Menu", id: Module.pianoConfigurationMenu.name) {
            PianoConfigurationMenu()
                .environment(appState)
                .environment(pianoManager)
        }.defaultSize(width: 500, height: 350)

        // MARK: The main immersive enviornment

        ImmersiveSpace(id: Module.immersiveSpace.name) {
            PianoRealityView()
                .environment(appState)
                .environment(pianoManager)
                .environment(handManager)
                .environment(playbackManager)
        }.immersionStyle(selection: $immersionStyle, in: .mixed)
    }
}
