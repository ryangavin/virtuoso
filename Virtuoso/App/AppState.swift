//
//  ViewModel.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/15/24.
//

import SwiftUI

@Observable
class AppState {
    // MARK: Actual App State

    var libraryDetailShown = false
    var selectedSong: Song?

    var showImmersiveSpace = false
    var immersiveSpaceIsShown = false

    var showConfigurationMenu = false
    var showTrainerWindow = false
    var showBrowserWindow = true

    var showAnchors = false

    func returnFromImmersiveSpace() {
        showImmersiveSpace = false
        showTrainerWindow = false
        showBrowserWindow = true
    }
}
