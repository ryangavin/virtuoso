//
//  DataController.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 3/17/24.
//

import SwiftData
import SwiftUI

@MainActor
enum DataController {
    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: SongCollection.self, configurations: config)

            // Set up the defaults
            addDefaults(container: container)

            // Add some user content
            let userSong1 = Song(belongsToUser: true, title: "User Song", artist: "User Artist")
            let userSong2 = Song(belongsToUser: true, title: "Another Song", artist: "User Artist")
            let userSong3 = Song(belongsToUser: true, title: "The Third Song", artist: "User Artist")
            container.mainContext.insert(userSong1)
            container.mainContext.insert(userSong2)
            container.mainContext.insert(userSong3)

            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()

    static let modelContainer: ModelContainer = {
        do {
            let container = try ModelContainer(for: SongCollection.self)

            // Make sure the persistent store is empty. If it's not, return the non-empty container.
            var itemFetchDescriptor = FetchDescriptor<SongCollection>()
            itemFetchDescriptor.fetchLimit = 1

            guard try container.mainContext.fetch(itemFetchDescriptor).count == 0 else { return container }

            addDefaults(container: container)

            return container
        } catch {
            fatalError("Failed to create container")
        }
    }()

    static func addDefaults(container: ModelContainer) {
        container.mainContext.insert(SongCollection.classicRockSongs)
        container.mainContext.insert(SongCollection.childrensSongs)
    }
}
