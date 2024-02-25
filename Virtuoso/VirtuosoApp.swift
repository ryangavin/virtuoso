//
//  VirtuosoApp.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/15/24.
//

import SwiftUI

@main
struct VirtuosoApp: App {
    @State private var model = AppState()
    @State private var handManager = HandManager()

    @State private var immersionStyle: ImmersionStyle = .mixed

    init() {
        print("Starting up!")
    }

    var body: some Scene {
        WindowGroup("Main Menu", id: Module.mainMenu.name) {
            MainMenu(appState: model)
        }.defaultSize(width: 400, height: 300)

        WindowGroup("Piano Configuration Menu", id: Module.pianoConfigurationMenu.name) {
            PianoConfigurationMenu(appState: model)
        }.defaultSize(width: 500, height: 350)

        ImmersiveSpace(id: Module.immersiveSpace.name) {
            PianoRealityView(appState: model, handManager: handManager)
        }.immersionStyle(selection: $immersionStyle, in: .mixed)
    }
}
