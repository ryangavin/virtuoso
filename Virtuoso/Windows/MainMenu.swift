//
//  ContentView.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/15/24.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct MainMenu: View {
    // All this stuff nees to be in a shared view model
    @Environment(AppModel.self) private var model

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    var body: some View {
        @Bindable
        var model = model

        VStack {
            Text("Welcome to Virtuoso XR")
                .font(/*@START_MENU_TOKEN@*/ .title/*@END_MENU_TOKEN@*/)

            Text("Immersive Piano Trainer")
                .padding(.top, 10)

            Toggle("Begin Training", isOn: $model.showImmersiveSpace)
                .toggleStyle(.button)
                .tint(.blue)
                .padding(.top, 10)
        }
        .padding()
        .onChange(of: model.showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: Module.immersiveSpace.name) {
                    case .opened:
                        model.immersiveSpaceIsShown = true
                        openWindow(id: Module.pianoConfigurationMenu.name)
                        openWindow(id: Module.anchorResetMenu.name)
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        model.immersiveSpaceIsShown = false
                        model.showImmersiveSpace = false
                    }
                } else if model.immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    model.immersiveSpaceIsShown = false
                }
            }
        }
        .onChange(of: model.showConfigurationMenu) { _, newValue in
            Task {
                if newValue {
                    openWindow(id: Module.pianoConfigurationMenu.name)
                } else {
                    dismissWindow(id: Module.pianoConfigurationMenu.name)
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    MainMenu().environment(AppModel())
}
