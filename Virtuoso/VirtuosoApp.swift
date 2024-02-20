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
            MainMenu(model: model)
        }.defaultSize(width: 400, height: 300)

        WindowGroup("Trainer Configuration Menu", id: Module.pianoConfigurationMenu.name) {
            PianoConfigurationMenu(model: model)
        }.defaultSize(width: 600, height: 450)

        // TODO: this maybe needs to be a volume???
        ImmersiveSpace(id: Module.immersiveSpace.name) {
            PianoRealityView(model: model)
        }.immersionStyle(selection: $immersionStyle, in: .mixed)
    }
}
