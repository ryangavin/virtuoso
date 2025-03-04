//
//  AppState.swift
//  Virtuoso
//
//  TODO: starting to wonder if this entire class should be dismantled
//  TODO: the thinking is that in so many places, this could actually be local state
//
//  Created by Ryan Gavin on 2/15/24.
//

import ObservableUserDefault
import SwiftUI

@Observable
class AppState {
    // MARK: Actual App State

    // TODO: maybe move this loadedSong to the PlaybackManager
    var loadedSong: Song?
    var showLoadingView = false

    var showSongEditor = false
    var editingSong: Song?

    var showImmersiveSpace = false
    var immersiveSpaceIsShown = false

    var showConfigurationMenu = false
    var showAnchors = false
    
    var showHelp = false

    func openLibraryEditor(with song: Song) {
        editingSong = song
        showSongEditor = true
    }

    func closeLibraryEditor() {
        showSongEditor = false
        editingSong = nil
    }
}
