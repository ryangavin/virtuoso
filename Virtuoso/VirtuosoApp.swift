//
//  VirtuosoApp.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/15/24.
//

import SwiftUI

@main
struct VirtuosoApp: App {
    @State private var model = AppModel()

    @State private var immersionStyle: ImmersionStyle = .mixed

    init() {
        print("Starting up!")
    }

    var body: some Scene {
        WindowGroup("Main Menu", id: Module.mainMenu.name) {
            MainMenu().environment(model)
        }.defaultSize(width: 400, height: 300)

        WindowGroup("Piano Configuration Menu", id: Module.pianoConfigurationMenu.name) {
            PianoConfigurationMenu().environment(model)
        }.defaultSize(width: 500, height: 350)

        ImmersiveSpace(id: Module.immersiveSpace.name) {
            PianoRealityView().environment(model)
        }.immersionStyle(selection: $immersionStyle, in: .mixed)
    }
}
