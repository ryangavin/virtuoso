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
        .frame(width: 300, height: 200, alignment: .leading)
        .padding(15)
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
                Button(action: {
                    appState.libraryDetailShown.toggle()
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

enum BrowserHeader: CaseIterable, Identifiable {
    var id: Self { return self }

    var title: String {
        switch self {
        case .lessons: return "Lessons"
        case .songs: return "Songs"
        case .exercises: return "Exercises"
        case .library: return "My Library"
            // case .stats: return "Stats"
            // case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .lessons: return "graduationcap.fill"
        case .songs: return "music.note.list"
        case .exercises: return "brain.filled.head.profile"
        case .library: return "book.fill"
            // case .stats: return "chart.bar"
            // case .settings: return "gear"
        }
    }

    case songs
    case lessons
    case exercises
    case library
    // case stats
    // case settings
}

struct BrowserView: View {
    @Environment(AppState.self) var appState

    @State var selectedHeader: BrowserHeader?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedHeader) {
                ForEach(BrowserHeader.allCases) { header in
                    NavigationLink(destination: {
                        switch selectedHeader {
                        case .songs:
                            BrowserListView()
                        case .lessons:
                            Text("Lessons")
                        case .exercises:
                            Text("Exercises")
                        case .library:
                            LibraryView()
                        // case .stats:
                        //     Text("Stats")
                        // case .settings:
                        //     Text("Settings")
                        case .none:
                            Text("None")
                        }
                    }) {
                        Label(header.title, systemImage: header.icon)
                    }
                }
            }.navigationTitle("Virtuoso")
        }
        detail: {
            BrowserListView()
        }
        .onAppear {
            selectedHeader = .songs
        }
    }
}

#Preview {
    BrowserView()
        .environment(AppState())
        .modelContainer(DataController.previewContainer)
}
