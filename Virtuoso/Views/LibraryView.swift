//
//  LibraryView.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 4/7/24.
//

import Foundation
import MIKMIDI
import SwiftData
import SwiftUI

struct LibraryEditView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(AppState.self) var appState

    @State var selectingMidiFile = false
    @State var tracks: [Song.Track] = []

    func loadMidiFile(_ url: URL) {
        let sequence = try! MIKMIDISequence(fileAt: url)
        tracks.removeAll()
        for track in sequence.tracks {
            tracks.append(Song.Track(trackNumber: track.trackNumber))
        }

        // Set the MIDI file name
        guard let editingSong = appState.editingSong else { return }
        editingSong.midiFile = url.relativePath
    }

    var body: some View {
        if let editingSong = appState.editingSong {
            @Bindable var bindableEditingSong = editingSong

            VStack {
                Form {
                    Section {
                        TextField("Title *", text: $bindableEditingSong.title)
                        TextField("Artist", text: $bindableEditingSong.artist)
                        TextField("Details", text: $bindableEditingSong.details)
                        Stepper(value: $bindableEditingSong.difficulty, in: 1 ... 5) {
                            HStack {
                                Text("Difficulty")
                                // show a number of stars based on the difficulty
                                ForEach(1 ... bindableEditingSong.difficulty, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                }
                                // show an empty star for the remaining difficulty
                                if bindableEditingSong.difficulty < 5 {
                                    ForEach(1 ... (5 - bindableEditingSong.difficulty), id: \.self) { _ in
                                        Image(systemName: "star")
                                    }
                                }
                            }
                        }
                    }

                    Section {
                        HStack {
                            Text("MIDI File: \(editingSong.midiFile)")

                            Button("Browse") {
                                selectingMidiFile = true
                            }
                            .tint(.accentColor)
                        }
                        .fileImporter(
                            isPresented: $selectingMidiFile,
                            allowedContentTypes: [.midi],
                            allowsMultipleSelection: false
                        ) { result in
                            switch result {
                            case .success(let url):
                                loadMidiFile(url.first!)
                            case .failure(let error):
                                print("Error selecting MIDI file: \(error)")
                            }
                        }
                    }

                    Section {
                        if appState.editingSong?.midiFile.isEmpty == true {
                            Text("Please select a MIDI file")
                        } else if tracks.isEmpty {
                            Text("No tracks found in MIDI file")
                        }

                        ForEach($tracks, id: \.self) { $track in
                            HStack {
                                // Always show the track number
                                Text("\(track.trackNumber)")
                                    .padding(.trailing, 20)

                                // Toggle for whether or not this track is a lesson track
                                Toggle("Trainer", isOn: $track.lessonTrack)
                                    .frame(width: 120)
                                    .padding(.trailing, 20)

                                // Only enable the hand picker if this is a lesson track
                                Picker("Hand", selection: $track.hand) {
                                    Text("Left").tag(Song.Track.Hand.left)
                                    Text("Right").tag(Song.Track.Hand.right)
                                    Text("Both").tag(Song.Track.Hand.both)
                                }
                                .disabled(!track.lessonTrack)
                                .frame(width: 160)

                                Spacer()

                                // Sound picker for the sequencer
                                Picker("Sound", selection: $track.sound) {
                                    ForEach(Song.Track.Sound.allCases, id: \.self) { sound in
                                        Text(sound.rawValue.capitalized).tag(sound)
                                    }
                                }
                                .frame(width: 200)
                            }
                        }
                    }
                }
                .padding(.bottom, 20)

                HStack {
                    Button("Discard Changes", action: {
                        appState.closeLibraryEditor()
                    })

                    Button("Save", action: {
                        modelContext.insert(editingSong)
                        appState.closeLibraryEditor()
                    })
                    .tint(.blue)
                    .disabled(
                        editingSong.midiFile.isEmpty || tracks.isEmpty || editingSong.title.isEmpty
                    )
                }
            }
            .frame(minWidth: 800, minHeight: 600)
            .padding([.top, .bottom], 25)
            .onAppear {
                // If we're editing a song, load the MIDI file
                if let editingSong = appState.editingSong {
                    if !editingSong.midiFile.isEmpty {
                        loadMidiFile(URL(fileURLWithPath: editingSong.midiFile))
                    }
                }
            }
        } else {
            Text("No song selected")
        }
    }
}

struct LibraryItemDetail: View {
    @Environment(AppState.self) var appState

    var body: some View {
        @Bindable var appStateBindable = appState

        VStack {
            // Title bar and close button
            HStack {
                Text(appState.selectedSong!.title)
                    .font(.title)
                Spacer()
                Button(action: {
                    appState.showSongDetail.toggle()
                }, label: {
                    Image(systemName: "xmark")
                })
            }

            // Content space
            HStack {
                Image("Placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
                    .padding(.trailing, 20)

                VStack {
                    Text(appState.selectedSong!.details)
                        .font(.subheadline)
                        .frame(width: 300, alignment: .leading)
                    Spacer()
                    Button("Start Training") {
                        appState.showSongDetail = false
                        appState.showImmersiveSpace = true
                    }
                    .tint(.blue)
                }
            }
        }
        .padding(20)
        .background {
            Image("Placeholder")
                .resizable()
                .blur(radius: 50)
                .brightness(-0.4)
                .opacity(0.4)
        }
    }
}

struct LibraryView: View {
    @Query(sort: \Song.title) private var allSongs: [Song]

    @Environment(AppState.self) var appState

    var body: some View {
        @Bindable var appStateBindable = appState

        NavigationStack {
            List {
                ForEach(allSongs, id: \.self) { song in
                    Button(action: {
                        appState.openSongDetail(with: song)
                    }, label: {
                        HStack {
                            // Show an animated note icon if the song is selected and trainer is active
                            if song.id == appState.selectedSong?.id && appState.immersiveSpaceIsShown {
                                Image(systemName: "music.note")
                                    .foregroundColor(.accentColor)
                                    .padding(.trailing, 10)
                            }

                            Text(song.title)
                            Text(song.artist)
                                .foregroundColor(.gray)

                            Spacer()

                            Text("Difficulty")
                                .foregroundColor(.gray)
                            // show a number of stars based on the difficulty
                            ForEach(1 ... song.difficulty, id: \.self) { _ in
                                Image(systemName: "star.fill")
                            }
                            // show an empty star for the remaining difficulty
                            if song.difficulty < 5 {
                                ForEach(1 ... (5 - song.difficulty), id: \.self) { _ in
                                    Image(systemName: "star")
                                }
                            }
                        }
                    })
                    .swipeActions {
                        // Destructive role seems to automatically add a red background and remove the label
                        Button(role: .destructive) {} label: {
                            // TODO: does this actually delete from the database
                            Label("Delete", systemImage: "trash")
                        }

                        // Don't allow the user to edit the default songs
                        // They can still be deleted
                        if song.belongsToUser {
                            Button {
                                appState.openLibraryEditor(with: song)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Virtuoso -  XR Piano Trainer")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        appState.openLibraryEditor(with: Song(belongsToUser: true))
                    }) {
                        Image(systemName: "plus")
                    }
                }

                if appState.showImmersiveSpace {
                    withAnimation {
                        ToolbarItem(placement: .bottomOrnament) {
                            PlaybackWidget()
                        }
                    }
                }
            }
        }
        .onAppear {
            // Load the immersive space right away
            appState.showImmersiveSpace = true

            // TODO: draw the piano
        }
        // Edit View
        .sheet(isPresented: $appStateBindable.showSongEditor) {
            LibraryEditView()
        }
        // Popover centered in the middle of the screen
        .sheet(isPresented: $appStateBindable.showSongDetail) {
            LibraryItemDetail()
        }
        // Setup Wizard
        .sheet(isPresented: $appStateBindable.showSetupWizard) {
            SetupWizard()
        }
        .sheet(isPresented: $appStateBindable.showConfigurationMenu) {
            PianoConfigurationMenu()
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static let dataController = DataController.previewContainer

    static var previews: some View {
        LibraryView()
            .environment(AppState())
            .modelContainer(dataController)
            .navigationTitle("My Song Library")
            .glassBackgroundEffect()
    }
}

struct LibraryViewEdit_Previews: PreviewProvider {
    static let appState = AppState()
    static let dataController = DataController.previewContainer

    static var previews: some View {
        LibraryView()
            .environment(appState)
            .modelContainer(dataController)
            .navigationTitle("My Song Library")
            .onAppear {
                appState.editingSong = Song(belongsToUser: true, title: "Test Song", artist: "Test Artist", details: "Test Details", difficulty: 5)
                appState.showSongEditor = true
            }
            .glassBackgroundEffect()
    }
}
