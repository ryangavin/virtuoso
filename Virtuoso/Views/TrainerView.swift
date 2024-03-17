//
//  TrainerView.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 3/16/24.
//

import Foundation
import SwiftUI

struct TrainerView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        NavigationStack {
            VStack {
                Image("PlaceholderMusic")
                    .resizable()
                    .scaledToFit()
            }
            .toolbar {
                ToolbarItem(placement: .bottomOrnament) {
                    PlaybackWidget()
                }
            }
        }.onAppear {
            appState.trainerWindowIsShown = true
        }.onDisappear {
            appState.trainerWindowIsShown = false
        }
    }
}

#Preview(windowStyle: .automatic) {
    TrainerView()
        .environment(AppState())
        .environment(PlaybackManager())
}
