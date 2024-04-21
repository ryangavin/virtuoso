//
//  AppState.swift
//  Virtuoso
//
//  TODO: starting to wonder if this entire class should be dismantled
//  TODO: the thinking is that in so many places, this could actually be local state
//
//  Created by Ryan Gavin on 2/15/24.
//

import SwiftUI

@Observable
class AppState {
    // MARK: Actual App State

    var showSongDetail = false
    var selectedSong: Song?

    var showSongEditor = false
    var editingSong: Song?

    var showImmersiveSpace = false
    var immersiveSpaceIsShown = false

    var showConfigurationMenu = false

    var showAnchors = false

    func startTraining() {
        showImmersiveSpace = true
        showSongDetail = false
    }

    func returnToBrowser() {
        showImmersiveSpace = false
        showSongDetail = selectedSong != nil ? true : false
    }

    func openSongDetail(with song: Song) {
        selectedSong = song
        showSongDetail = true
    }

    func closeSongDetail() {
        showSongDetail = false
        selectedSong = nil
    }

    func openLibraryEditor(with song: Song) {
        editingSong = song
        showSongEditor = true
    }

    func closeLibraryEditor() {
        showSongEditor = false
        editingSong = nil
    }
}
