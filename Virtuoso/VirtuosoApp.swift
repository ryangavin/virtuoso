//
//  VirtuosoApp.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/15/24.
//

import SwiftUI

@main
struct VirtuosoApp: App {
    @State private var model = ViewModel()

    @State private var immersionStyle: ImmersionStyle = .mixed

    init() {
        print("Starting up!")
    }

    var body: some Scene {
        WindowGroup("Main Menu", id: "MainMenu") {
            MainMenu().environment(model)
        }.defaultSize(width: 400, height: 300)

        WindowGroup("Trainer Configuration Menu", id: "TrainerConfigurationMenu") {
            PianoConfigurationMenu()
        }.defaultSize(width: 400, height: 800)

        ImmersiveSpace(id: "ImmersiveSpace") {
            PianoContent().environment(model)
        }.immersionStyle(selection: $immersionStyle, in: .mixed)
    }
}
