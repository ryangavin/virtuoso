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
    }
}

@MainActor
func onDismiss() {
    print("Dismissing")
}

#Preview(windowStyle: .automatic) {
    TrainerView()
        .environment(AppState())
        .environment(PlaybackManager())
}
