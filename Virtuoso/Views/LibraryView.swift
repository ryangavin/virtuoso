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
                        Stepper("Difficulty: \(editingSong.difficulty)", value: $bindableEditingSong.difficulty, in: 1 ... 10)
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

struct LibraryView: View {
    @Query(filter: #Predicate<Song> { song in
        song.belongsToUser == true
    }, sort: \Song.title) private var userSongs: [Song]

    @Environment(AppState.self) var appState

    var body: some View {
        @Bindable var appStateBindable = appState

        List {
            ForEach(userSongs, id: \.self) { song in
                Button(song.title, action: {
                    appState.openSongDetail(with: song)
                })
                .swipeActions {
                    // Destructive role seems to automatically add a red background and remove the label
                    Button(role: .destructive) {} label: {
                        // TODO: does this actually delete from the database
                        Label("Delete", systemImage: "trash")
                    }

                    Button {
                        appState.openLibraryEditor(with: song)
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
        }
        .navigationTitle("My Song Library")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    appState.openLibraryEditor(with: Song(belongsToUser: true))
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        // Edit View
        .sheet(isPresented: $appStateBindable.showSongEditor) {
            LibraryEditView()
        }
        // Popover centered in the middle of the screen
        .sheet(isPresented: $appStateBindable.songDetailShown) {
            BrowserItemDetail()
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static let dataController = DataController.previewContainer

    static var previews: some View {
        NavigationSplitView {} detail: {
            LibraryView()
                .environment(AppState())
                .modelContainer(dataController)
                .navigationTitle("My Song Library")
        }
        .glassBackgroundEffect()
    }
}

struct LibraryViewEdit_Previews: PreviewProvider {
    static let appState = AppState()
    static let dataController = DataController.previewContainer

    static var previews: some View {
        NavigationSplitView {} detail: {
            LibraryView()
                .environment(appState)
                .modelContainer(dataController)
                .navigationTitle("My Song Library")
                .onAppear {
                    appState.editingSong = Song(belongsToUser: true, title: "Test Song", artist: "Test Artist", details: "Test Details", difficulty: 5)
                    appState.showSongEditor = true
                }
        }
        .glassBackgroundEffect()
    }
}
