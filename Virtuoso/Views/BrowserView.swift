//
//  BrowserView.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 3/10/24.
//

import SwiftData
import SwiftUI

struct BrowserListItem: View {
    @Environment(AppState.self) var appState

    let song: Song

    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "star")
            Spacer()
            Text(song.title).font(.title2)
            Text(song.artist).font(.title3)
        }
        .padding(15)
        .frame(width: 300, height: 200, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .hoverEffect(.lift)
        .onTapGesture {
            appState.selectedSong = song
            appState.libraryDetailShown.toggle()
        }
    }
}

struct BrowserSection: View {
    let title: String
    let collection: SongCollection

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .padding(.bottom, 10)
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(collection.songs) { song in
                        BrowserListItem(song: song)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct BrowserItemDetail: View {
    @Environment(AppState.self) var appState

    var body: some View {
        @Bindable var appStateBindable = appState

        VStack {
            // Title bar and close button
            HStack {
                Text(appState.selectedSong!.title)
                    .font(.title)
                Spacer()
                Button(action: { appState.libraryDetailShown.toggle() }, label: {
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

                Spacer()

                VStack {
                    Text("Description of the lesson. Explain to the user what's going on. Maybe bullet points for what we will learn. Be as descriptive as possible.")
                        .font(.subheadline)
                    Spacer()
                    Button("Start Training") {
                        appState.showImmersiveSpace = true
                    }
                    .tint(.blue)
                }
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 700, alignment: .leading)
        .background {
            Image("Placeholder")
                .resizable()
                .blur(radius: 50)
                .brightness(-0.4)
                .opacity(0.4)
        }
    }
}

struct BrowserListView: View {
    @Environment(AppState.self) var appState

    @Query private var allSongCollections: [SongCollection]

    var body: some View {
        @Bindable var appStateBindable = appState

        ScrollView {
            ForEach(allSongCollections) { songCollection in
                BrowserSection(title: songCollection.title, collection: songCollection)
            }

            Spacer()
        }
        .navigationTitle("Lessons")
        .padding(25)

        // Popover centered in the middle of the screen
        .sheet(isPresented: $appStateBindable.libraryDetailShown) {
            BrowserItemDetail()
        }
    }
}

struct BrowserView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        NavigationSplitView {
            List {
                Button(action: {}, label: {
                    HStack {
                        Image(systemName: "graduationcap.fill")
                        Text("Lessons")
                    }
                })
                Button(action: {}, label: {
                    HStack {
                        Image(systemName: "music.note.list")
                        Text("Songs")
                    }
                })
                Button(action: {}, label: {
                    HStack {
                        Image(systemName: "brain.filled.head.profile")
                        Text("Exercises")
                    }
                })
                Button(action: {}, label: {
                    HStack {
                        Image(systemName: "chart.bar")
                        Text("Stats")
                    }
                })
                Button(action: {}, label: {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                })
            }.navigationTitle("Virtuoso")
        }
        detail: {
            BrowserListView()
        }
        .onAppear {
            appState.browserWindowIsShown = true
        }
        .onDisappear {
            appState.browserWindowIsShown = false
        }
    }
}

#Preview("Browser") {
    BrowserView()
        .environment(AppState())
        .modelContainer(DataController.previewContainer)
}

#Preview("Browser Detail Sheet") {
    BrowserItemDetail().environment(AppState())
        .glassBackgroundEffect()
        .frame(width: 700, height: 300)
}
