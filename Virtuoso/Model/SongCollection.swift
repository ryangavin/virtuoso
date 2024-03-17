//
//  Course.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 3/10/24.
//

import Foundation
import SwiftData

@Model
final class SongCollection {
    var title: String
    var details: String
    var difficulty: Int

    @Relationship(deleteRule: .cascade)
    var songs: [Song]

    init(title: String, details: String, difficulty: Int = 1, songs: [Song] = []) {
        self.title = title
        self.details = details
        self.difficulty = difficulty
        self.songs = songs
    }
}
