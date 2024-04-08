//
//  LibraryView.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 4/7/24.
//

import Foundation
import SwiftData
import SwiftUI

struct LibraryEditView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        if let editingSong = appState.editingSong {
            VStack {
                Text(editingSong.title)
                    .font(.title)
                    .padding(.bottom, 10)
                Text(editingSong.artist)
                    .font(.title2)
                    .padding(.bottom, 40)

                HStack {
                    Button("Discard Changes", action: {
                        appState.closeLibraryEditor()
                    })

                    Button("Save", action: {
                        appState.closeLibraryEditor()
                    }).tint(.blue)
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
                    appState.selectedSong = song
                    appState.songDetailShown.toggle()
                })
                .swipeActions {
                    // Destructive role seems to automatically add a red background and remove the label
                    Button(role: .destructive) {} label: {
                        // TODO: does this actually delete from the database
                        Label("Delete", systemImage: "trash")
                    }

                    Button {
                        appState.editingSong = song
                        appState.showSongEditor = true
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
                    print("Add button tapped")
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
