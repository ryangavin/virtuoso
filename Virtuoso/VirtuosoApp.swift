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
    @State private var playbackManager = PlaybackManager()

    @State private var immersionStyle: ImmersionStyle = .mixed

    init() {
        print("Starting up!")
    }

    var body: some Scene {
//        WindowGroup("Main Menu", id: Module.mainMenu.name) {
//            MainMenu()
//                .environment(appState)
//                .environment(playbackManager)
//        }.defaultSize(width: 600, height: 280)

        WindowGroup("Browser", id: Module.browser.name) {
            BrowserView()
                .environment(appState)
        }

        WindowGroup("Piano Configuration Menu", id: Module.pianoConfigurationMenu.name) {
            PianoConfigurationMenu(appState: appState)
        }.defaultSize(width: 500, height: 350)

        ImmersiveSpace(id: Module.immersiveSpace.name) {
            PianoRealityView()
                .environment(appState)
                .environment(handManager)
                .environment(playbackManager)
        }.immersionStyle(selection: $immersionStyle, in: .mixed)
    }
}
