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
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    @State private var showConfigurationMenu = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow

    var body: some View {
        VStack {
            Text("Welcome to Virtuoso XR")
                .font(/*@START_MENU_TOKEN@*/ .title/*@END_MENU_TOKEN@*/)

            Text("Immersive Piano Trainer")
                .padding(.top, 10)

            Toggle("Settings", isOn: $showConfigurationMenu)
                .toggleStyle(.button)
                .padding(.top, 50)

            Toggle("Begin Training", isOn: $showImmersiveSpace)
                .toggleStyle(.button)
                .padding(.top, 10)
        }
        .padding()
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
        .onChange(of: showConfigurationMenu) { _, newValue in
            Task {
                if newValue {
                    openWindow(id: "TrainerConfigurationMenu")
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    MainMenu()
}
