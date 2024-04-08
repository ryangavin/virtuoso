//
//  LibraryView.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 4/7/24.
//

import Foundation
import SwiftData
import SwiftUI

struct LibraryItemDetail: View {
    let selectedSong: Song

    var body: some View {
        VStack {
            Text(selectedSong.title)
                .font(.title)
                .padding(.bottom, 10)
            Text(selectedSong.artist)
                .font(.title2)
                .padding(.bottom, 40)
        }
    }
}

struct LibraryView: View {
    @Query(filter: #Predicate<Song> { song in
        song.belongsToUser == true
    }, sort: \Song.title) private var userSongs: [Song]

    var body: some View {
        List {
            ForEach(userSongs, id: \.self) { song in
                Text(song.title)
                    .swipeActions {
                        // Destructive role seems to automatically add a red background and remove the label
                        Button(role: .destructive) {} label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            print("Edit button tapped for \(song)")
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
    }
}

#Preview {
    NavigationSplitView {} detail: {
        NavigationStack {
            LibraryView()
                .modelContainer(DataController.previewContainer)
                .navigationTitle("My Song Library")
        }
    }
}
